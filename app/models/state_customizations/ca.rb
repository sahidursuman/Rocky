#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****

class CA < StateCustomization
  class RegistrantBinding
    
    attr_reader :registrant
    
    delegate :email_address,
      :first_name, :middle_name, :last_name,
      :prev_first_name, :prev_middle_name, :prev_last_name,
      :home_address, :home_unit, :home_city, :home_state_name, :home_zip_code,
      :mailing_address, :mailing_unit, :mailing_city, :mailing_state_name, :mailing_zip_code,
      :prev_address, :prev_unit, :prev_city, :prev_state_name, :prev_zip_code, 
      :to=>:registrant
    
    def initialize(r)
      @registrant = r
    end
    
    delegate :api_url, :api_key, :api_posting_entity_name, :to=>:api_settings
    
    def api_settings
      RockyConf.ovr_states.CA.api_settings
    end
    
    def us_citizen?
      registrant.us_citizen? ? '1' : '0'
    end
    
    def will_be_18_by_election?
      registrant.will_be_18_by_election? ? '1' : '0'
    end
    
    def dob_day
      registrant.date_of_birth.day
    end
    def dob_month
      registrant.date_of_birth.month
    end
    def dob_year
      registrant.date_of_birth.year
    end
    
    def phone
      registrant.phone_digits
    end
    
    def has_home_address?
      1
    end
    
    def has_mailing_address?
      registrant.has_mailing_address ? '1' : '0'
    end
    
    def has_prev_address?
      registrant.change_of_address? ? '1' : '0'
    end
    
    
    
    # 1 Other
    # 2 American Indian or Alaska Native
    # 3 Asian or Pacific Islander
    # 4 Black, not of Hispanic Origin
    # 5 Hispanic
    # 6 Multi-racial
    # 7 White, not of Hispanic Origin
    def ethnicity_id
      case registrant.race_key.to_s
      when 'american_indian_alaskan_native'
        2
      when 'asian'
        3
      when 'black_not_hispanic'
        4
      when 'hispanic'
        5
      when 'mutli_racial'
        6
      when 'white_not_hispanic'
        7
      when 'other'
        1
      else
        ""
      end
    end
    
    # 2 English
    # 3 Chinese
    # 4 Vietnamese
    # 5 Korean
    # 6 Tagalog
    # 7 Japanese
    # 8 Hindi
    # 9 Khmer
    # 10 Thai
    # 11 Spanish
    def language_id
      case registrant.locale.to_s
      when 'en'
        2
      when 'cn-zh', 'cn-tw'
        3
      when 'vi'
        4
      when 'ko'
        5
      when 'tl'
        6
      when 'ja'
        7
      when 'hi'
        8
      when 'km'
        9
      when 'th'
        10
      when 'es'
        11
      else
        ""
      end        
    end
    
    
    
    
    # 1 Mr.
    # 2 Mrs.
    # 3 Miss
    # 4 Ms.
    def name_prefix_id
      case registrant.name_title_key.to_s
      when 'mr'
        1
      when 'mrs'
        2
      when 'miss'
        3
      when 'ms'
        4
      else
        ""
      end
    end
    
    
    def get_binding
      binding
    end
    
  end
  
  
  XML_TOKEN_REGEXP = /\<Token\>(.+)\<\/Token\>/
  
  def has_ovr_pre_check?(registrant)
    true
  end
  
  def ovr_pre_check(registrant, controller)
    request_xml = self.class.build_soap_xml(registrant)
    api_response = self.class.request_token(request_xml)
    
    if RockyConf.ovr_states.CA.api_settings.debug_in_ui
      controller.render :xml=>api_response, :layout=>nil, :content_type=>"application/xml"
    else
      raise 'NOT HERE YET'
      # 4. Else, parse response
      # 5. if "success", mark as such
      # 6. Go to page 4 (which, for CA, may or may not include the "finish with state" option)
      
      token = self.class.extract_token_from_xml_response(api_response)
      if token.blank?
        
      else
      end
    end
  end
  
  def self.build_soap_xml(registrant)
    ERB.new(File.new(soap_xml_erb_file).read).result(RegistrantBinding.new(registrant).get_binding)
  end
  
  def self.soap_xml_erb_file
    Rails.root.join("app/models/state_customizations/ca/soap_request.xml.erb")
  end
  
  def self.request_token(request_xml)
    if RockyConf.ovr_states.CA.api_settings.log_all_requests
      Rails.logger.info("Making Request to: #{RockyConf.ovr_states.CA.api_settings.api_url}")
      Rails.logger.info("With XML #{request_xml}")
    end
    begin
      raise 'a'
      Integrations::Soap.make_request(RockyConf.ovr_states.CA.api_settings.api_url, request_xml)
    rescue Exception => e
      if RockyConf.ovr_states.CA.api_settings.log_all_requests
        Rails.logger.info(e)
      end
      nil
    end
  end
  
  def self.extract_token_from_xml_response(xml_string)
    if xml_string =~ XML_TOKEN_REGEXP
      return $1
    else
      return nil
    end
  end
  
end