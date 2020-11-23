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