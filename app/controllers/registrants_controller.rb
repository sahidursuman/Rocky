class RegistrantsController < ApplicationController
  include RegistrationStep

  def landing
    if Rails.env.development?
      redirect_to new_registrant_url
    else
      redirect_to new_registrant_url(:protocol => "https")
    end
  end

  # GET /registrants/new
  def new
    set_up_locale
    @registrant = Registrant.new(:partner_id => session[:partner_id], :locale => session[:locale])
    render "show"
  end

  # POST /registrants
  def create
    set_up_locale
    @registrant = Registrant.new(params[:registrant].reverse_merge(
                                    :locale => session[:locale],
                                    :partner_id => session[:partner_id],
                                    :opt_in_sms => true, :opt_in_email => true))
    attempt_to_advance
  end

  def ineligible
    find_registrant
  end

  def timeout
    @current_step = 0
  end

  def download
    @current_step = 6
    find_registrant(:download)
  end

  def finish
    
  end

  def current_step
    @current_step ||= 1
  end

  hide_action :current_step

  protected

  def set_up_locale
    session[:locale] = params[:locale] || session[:locale] || 'en'
    I18n.locale = session[:locale].to_sym
    @alt_locale = (session[:locale] == 'en' ? 'es' : 'en')
  end

  def advance_to_next_step
    @registrant.advance_to_step_1
  end

  def next_url
    registrant_step_2_url(@registrant)
  end
end
