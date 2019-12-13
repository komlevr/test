class CheckAllDomainsWorker
  include Sidekiq::Worker
  def logger
    @@logger ||= Logger.new("#{Rails.root}/log/backgroud_task.log")
  end

  def perform()
    logger.info("start task")

    certs = Cert.all
    certs.each do |item| 	
      begin
        ctx = OpenSSL::SSL::SSLContext.new
        sock = TCPSocket.new(item.domain, 443)
        ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
        ssl.connect
        cert = OpenSSL::X509::Certificate.new(ssl.peer_cert)
        ssl.sysclose
        sock.close
      rescue Exception => err
        logger.info("#{err}")
        cer = Cert.find_by(id: item.id)
        cer.status = "1"
        cer.comment = "Хост не существует"
        cer.save
        next
      end


      cer = Cert.find_by(id: item.id)
      if ssl.verify_result.to_s.blank?
        cer.status = "1"
        cer.comment = "Сертификат не валиден"
      else
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
    logger.info("stop task")
  end
end
