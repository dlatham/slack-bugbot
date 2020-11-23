# Load the GPG private keys from ENV variables for decryption services

if Rails.env == 'production'
	GPGME::Key.import(ENV['GPG_KEY'])
end