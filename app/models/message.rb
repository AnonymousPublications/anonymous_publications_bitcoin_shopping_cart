class Message < ActiveRecord::Base
  attr_accessible :body, :header, :message_type, :message_status
  
  def status
    case message_status
    when "read"
      return :read
    when "unread"
      return :unread
    when "deleted"
      return :deleted
    end
  end
  
  # header should be a quick note,
  # body should be the exception.txt + the line number from where the 
  # emergency was created and anything else relevant
  def self.emergency(m_header, m_body = nil)
    self.create(body: m_body, header: m_header, message_type: "emergency")
  end
  
  def self.conducting_mass_dl_from_blockchain
    self.create(body: "conducting mass dl from blockchain, don't do this often",
                header: "mass_dl_blockchain",
                message_type: "mass-dl")
  end
  
  def self.conducted_mass_dl_from_blockchain_within_24h?
    latest_dl = self.where(message_type: "mass-dl").last
    return false if latest_dl.nil?
    return false if latest_dl.created_at > Time.zone.now - 24.hours
    true
  end
  
  def inspect
    "\n#{header}\n\n#{body}\n"
  end
  
  
end
