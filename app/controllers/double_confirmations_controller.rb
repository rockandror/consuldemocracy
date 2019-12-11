class DoubleConfirmationsController < ApplicationController
    skip_authorization_check
    before_action :user_can_access?, except: [:user_blocked]

    def no_phone

    end

    def user_blocked
        
    end

    def request_access_key
        
    end

    def new_password_sent
        unless current_user.blank?
            new_access_key_length = 10
            new_access_key = "aAbcdeEfghiJkmnpqrstuUvwxyz23456789$!".split("").sample(10).join("")
            encrypted_access_key = encrypt_access_key(new_access_key)
            current_user.update_attributes(:access_key_generated => encrypted_access_key, :access_key_generated_at => Time.now)

            send_sms(new_access_key)
            redirect_to request_access_key_double_confirmations_path, notice: I18n.t("admin.double_verification.new_password_sent")
        else
            redirect_to request_access_key_double_confirmations_path, alert: I18n.t("admin.double_verification.new_password_sent_failed")
        end
    end

    def request_post_access_key
        if !current_user.blank? && !params[:access_key].blank?
            access_count= (current_user.access_key_tried.to_i) + 1
            access_key_inserted_encrypted = encrypt_access_key(params[:access_key]) 
            current_user.update(access_key_inserted: access_key_inserted_encrypted)
            if current_user.access_key_tried < 3 
                current_user.update(access_key_tried: access_count)
                redirect_to request_access_key_double_confirmations_path, alert: I18n.t("admin.double_verification.access_key_error")
            else
                block_user
                sign_out
                redirect_to user_blocked_double_confirmations_path
            end
        else
            redirect_to request_access_key_double_confirmations_path
        end
    end

    private
    def send_sms(access_key)
        SMSApi.new.sms_deliver(current_user.confirmed_phone, access_key)
    end

    def block_user
        current_user.block
        Activity.log(current_user, :block, @user)
    end

    def user_can_access?
        if current_user.blank?
            redirect_to welcome_path, alert: I18n.t("admin.double_verification.no_logged")
        elsif current_user.double_verification?
            redirect_to welcome_path, notice: I18n.t("admin.double_verification.double_conmfirmed")
        elsif current_user.phone_number_present?
            no_phone_double_confirmations_path
        end
    end

    def encrypt_access_key(access_key)
        unless current_user.blank? 
            Criptografia.new.encrypt(access_key)
        end
    end
end
