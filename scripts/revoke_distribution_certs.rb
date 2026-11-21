# Revokes all existing Apple Distribution certificates for the team so the
# build can always create exactly one fresh certificate (CI runners are
# ephemeral: a certificate's private key never survives to the next run, so
# reusing old certificates is impossible and the quota otherwise fills up).
# Stdlib only. Auth: App Store Connect API key from env (ES256 JWT).
require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

KEY_ID = ENV.fetch('ASC_KEY_ID')
ISSUER = ENV.fetch('ASC_ISSUER_ID')
KEY_PEM = Base64.decode64(ENV.fetch('ASC_KEY_CONTENT'))

def b64url(data)
  Base64.urlsafe_encode64(data, padding: false)
end

def jwt_token
  ec = OpenSSL::PKey.read(KEY_PEM)
  now = Time.now.to_i
  header = { 'alg' => 'ES256', 'kid' => KEY_ID, 'typ' => 'JWT' }
  payload = { 'iss' => ISSUER, 'iat' => now, 'exp' => now + 900, 'aud' => 'appstoreconnect-v1' }
  input = "#{b64url(header.to_json)}.#{b64url(payload.to_json)}"
  der = ec.sign(OpenSSL::Digest::SHA256.new, input)
  seq = OpenSSL::ASN1.decode(der)
  r = seq.value[0].value.to_s(2).rjust(32, "\x00")[-32, 32]
  s = seq.value[1].value.to_s(2).rjust(32, "\x00")[-32, 32]
  "#{input}.#{b64url(r + s)}"
end

def api(method, path)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = case method
        when :get then Net::HTTP::Get.new(uri)
        when :delete then Net::HTTP::Delete.new(uri)
        end
  req['Authorization'] = "Bearer #{jwt_token}"
  req['Content-Type'] = 'application/json'
  http.request(req)
end

res = api(:get, '/v1/certificates?filter%5BcertificateType%5D=DISTRIBUTION&limit=50')
unless res.code.to_i == 200
  warn "Could not list certificates: HTTP #{res.code} #{res.body}"
  exit 1
end

certs = JSON.parse(res.body)['data'] || []
puts "Found #{certs.length} distribution certificate(s)."
certs.each do |c|
  attrs = c['attributes'] || {}
  del = api(:delete, "/v1/certificates/#{c['id']}")
  if [204, 404].include?(del.code.to_i)
    puts "Revoked #{attrs['serialNumber']} (#{attrs['name']})"
  else
    warn "Failed to revoke #{c['id']}: HTTP #{del.code} #{del.body}"
    exit 1
  end
end
puts 'Certificate cleanup done.'
