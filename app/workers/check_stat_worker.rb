class CheckStatWorker
  require 'socket'
  require 'openssl'
  include OpenSSL
  include Sidekiq::Worker

  def perform(host, id) 
    begin
      ctx = OpenSSL::SSL::SSLContext.new
      sock = TCPSocket.new(host, 443) 
      ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
      ssl.connect
      cert = OpenSSL::X509::Certificate.new(ssl.peer_cert)
      ssl.sysclose
      sock.close
    rescue Exception => err
      puts err
      cer = Cert.find_by(id: id)
      cer.status = "1"
      cer.comment = "Хост не существует"
      cer.save
      return
    end

    cer = Cert.find_by(id: id)
      if ssl.verify_result.to_s.blank?
        cer.status = "1"
        cer.comment = "Сертификат не валиде"
      elsif
        if cert.not_after.nil?
          cer.status = "1"
          cer.comment = "Сертификат не валиден"
        elsif cert.not_after < Time.new
          cer.status = "1"
          cer.comment = "Сертификат умер"
        elsif cert.not_after < Time.new + 14.days
          cer.status = "0"
          cer.comment = "Умрет менне чем через 2 недели"
        elsif cert.not_after < Time.new + 7.days
          cer.status = "0"
          cer.comment = "Умрет менее чем через неделю"
        else
          cer.status = "0"
          cer.comment = "Все огонь"
        end
      end
    cer.save
  end
end
