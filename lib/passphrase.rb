# Used by GPGME to generate the passphrase when decrypting a file

class PassphraseCallback
  def initialize(passphrase)
    @passphrase = passphrase
  end

  def call(*args)
    fd = args.last
    io = IO.for_fd(fd, 'w')
    io.puts(@passphrase)
    io.flush
  end
end


class RoadsterGPG
	def initialize(options)
		@encrypted_file = options[:encrypted_file]
		@decrypted_file = options[:decrypted_file]
	end

	def decrypt
		if @encrypted_file.nil?
			return nil
		end

		crypto = GPGME::Crypto.new
		options = {passphrase_callback: PassphraseCallback.new(ENV['GPG_PASSPHRASE'])}
		data = crypto.decrypt @encrypted_file.read, options

		return data.to_s
	end
end
