class Transfer < ApplicationRecord
  belongs_to :customer
  belongs_to :player
  belongs_to :ez_cash_transaction, class_name: "Transaction", :foreign_key => "ezcash_tran_id"
  
#  after_create :transfer_web_service_call
  after_create :update_player
  after_create :ezcash_transaction_web_service_call
  after_update :ezcash_transaction_reversal_web_service_call
  
#  validates :from_account, :to_account, :amount, :fee, presence: true
#  validate :amount_not_greater_than_available

  #############################
  #     Instance Methods      #
  ############################
  
  
  ### Start Virtual Attributes ###
  def amount # Getter
    amount_cents.to_d / 100 if amount_cents
  end
  
  def amount=(dollars) # Setter
    self.amount_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def caddy_fee # Getter
    caddy_fee_cents.to_d / 100 if caddy_fee_cents
  end
  
  def caddy_fee=(dollars) # Setter
    self.caddy_fee_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def caddy_tip # Getter
    caddy_tip_cents.to_d / 100 if caddy_tip_cents
  end
  
  def caddy_tip=(dollars) # Setter
    self.caddy_tip_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def fee # Getter
    fee_cents.to_d / 100 if fee_cents
  end
  
  def fee=(dollars) # Setter
    self.fee_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def from_account # Getter
    from_account_id if from_account_id
  end
  
  def from_account=(id) # Setter
    self.from_account_id = id if id.present?
  end
  
  def to_account # Getter
    to_account_id if to_account_id
  end
  
  def to_account=(id) # Setter
    self.to_account_id = id if id.present?
  end
  ### End Virtual Attributes ###
  
  def from_account_record
    Account.find(from_account_id)
  end
  
  def to_account_record
    Account.find(to_account_id)
  end
  
  def amount_not_greater_than_available
    errors.add(:amount, "cannot be greater than available balance of #{from_account_record.available_balance}") if self.amount > from_account_record.available_balance
  end
  
  def transfer_web_service_call
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:EZCWSIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
       <SOAP-ENV:Body>
          <mns:SendTxnBlock xmlns:mns='urn:EZCWSIntf-IEZCWS' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
             <TxnBlock xsi:type='ns1:TTxnBlock'>
                <AcctCount xsi:type='xs:int'>2</AcctCount>
                <Accts xsi:type='soapenc:Array' soapenc:arrayType='ns1:TAccountInfo[1]'>
                   <item xsi:type='ns1:TAccountInfo'>
                      <AcctType xsi:type='ns1:TAcctTypeEnum'>atAdd</AcctType>
                      <ActID xsi:type='xs:int'>#{from_account_id}</ActID>
                      <Amount xsi:type='xs:double'>#{amount}</Amount>
                      <AuxText xsi:type='xs:string' />
                      <AvailBal xsi:type='xs:double'>#{from_account_record.available_balance}</AvailBal>
                      <BtnIndex xsi:type='xs:int'>0</BtnIndex>
                      <ButtonText xsi:type='xs:string'>#{from_account_record.name}</ButtonText>
                      <DepositFlag xsi:type='xs:boolean'>1</DepositFlag>
                      
                      <Fee xsi:type='xs:double'>0</Fee>
                      <FeeRequest xsi:type='xs:boolean'>1</FeeRequest>
                      <GroupID xsi:type='xs:int'>0</GroupID>
                      <NavToGroupID xsi:type='xs:int'>0</NavToGroupID>
                      <ParentID xsi:type='xs:int'>0</ParentID>
                      <IsBankAccount xsi:type='xs:boolean'>0</IsBankAccount>
                      <ActTypeID xsi:type='xs:int'>0</ActTypeID>
                      <Active xsi:type='xs:boolean'>1</Active>
                   </item>
                   <item xsi:type='ns1:TAccountInfo'>
                      <AcctType xsi:type='ns1:TAcctTypeEnum'>atMove</AcctType>
                      <ActID xsi:type='xs:int'>#{to_account_id}</ActID>
                      <Amount xsi:type='xs:double'>#{amount - fee}</Amount>
                      <AuxText xsi:type='xs:string' />
                      <AvailBal xsi:type='xs:double'>0</AvailBal>
                      <BtnIndex xsi:type='xs:int'>1</BtnIndex>
                      <ButtonText xsi:type='xs:string'>#{to_account_record.name}</ButtonText>
                      <DepositFlag xsi:type='xs:boolean'>0</DepositFlag>
                      
                      <Fee xsi:type='xs:double'>0</Fee>
                      <FeeRequest xsi:type='xs:boolean'>1</FeeRequest>
                      <GroupID xsi:type='xs:int'>0</GroupID>
                      <NavToGroupID xsi:type='xs:int'>0</NavToGroupID>
                      <ParentID xsi:type='xs:int'>0</ParentID>
                      <IsBankAccount xsi:type='xs:boolean'>0</IsBankAccount>
                      <ActTypeID xsi:type='xs:int'>0</ActTypeID>
                      <Active xsi:type='xs:boolean'>1</Active>
                   </item>
                </Accts>
                <CheckCount xsi:type='xs:int'>0</CheckCount>
                <Checks xsi:type='soapenc:Array' soapenc:arrayType='ns1:TCheckInfo[0]' />
                <CustomerID xsi:type='xs:int'>#{customer.CustomerID}</CustomerID>
                <Status xsi:type='ns1:TStatusType'>stProcess</Status>
                <User xsi:type='xs:string'>ezcash</User>
             </TxnBlock>
          </mns:SendTxnBlock>
       </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:send_txn_block, xml: xml_string)
    data = response.to_hash
  end
  
  def ezcash_transaction_web_service_call_xml
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TranactIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
       <SOAP-ENV:Body>
          <mns:EZCashTxn xmlns:mns='urn:TranactIntf-ITranact' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <FromActID xsi:type='xs:int'>#{from_account_id}</FromActID>
            <ToActID xsi:type='xs:int'>#{to_account_id}</ToActID>
            <Amount xsi:type='xs:double'>#{amount}</Amount>
          </mns:EZCashTxn>
       </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:ez_cash_txn, xml: xml_string)
    data = response.to_hash
  end
  
  def ezcash_transaction_web_service_call
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:ez_cash_txn, message: { FromActID: from_account_id, ToActID: to_account_id, Amount: amount })
    Rails.logger.debug "Response body: #{response.body}"
    if response.success?
      unless response.body[:ez_cash_txn_response].blank? or response.body[:ez_cash_txn_response][:return].to_i > 0
        self.ez_cash_tran_id = response.body[:ez_cash_txn_response][:tran_id]
        self.save
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def ezcash_transaction_reversal_web_service_call
    if reversed?
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      response = client.call(:ez_cash_txn, message: { TranID: ez_cash_tran_id })
      Rails.logger.debug "Response body: #{response.body}"
    end
  end
  
  def amount_in_dollars
    amount_cents / 100
  end
  
  def fee_in_dollars
    fee_cents / 100
  end
  
  def total
    (amount_cents - fee_cents) / 100
  end
  
  def update_player
    player.update_attributes(status: 'paid', fee: caddy_fee, tip: caddy_tip)
    unless player.event.not_paid? 
      # Payment has been processed for all players
      player.event.update_attribute(:color, 'green')
    end
  end
  
  def to_account
    Account.where(ActID: to_account_id).first
  end
  
  def to_customer
    to_account.customer unless to_account.blank?
  end
  
  def reversable?
    not ez_cash_tran_id.blank? and not reversed?
  end
  
  #############################
  #     Class Methods         #
  #############################
end
