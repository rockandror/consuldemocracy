class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @users = User.by_username_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def destroy
    id_aux = @user.id
    begin
      ActiveRecord::Base.transaction do
        Administrator.where(user_id: id_aux).each do |admin|
          admin.destroy
        end
        Valuator.where(user_id: id_aux).each do |valuator|
          valuator.destroy
        end
        Moderator.where(user_id: id_aux).each do |valuator|
          valuator.destroy
        end
        Manager.where(user_id: id_aux).each do |valuator|
          valuator.destroy
        end
        Organization.where(user_id: id_aux).each do |org|
          org.destroy
        end
        Lock.where(user_id: id_aux).each do |lock|
          lock.destroy
        end
        Image.where(user_id: id_aux).each do |image|
          image.destroy
        end
        Flag.where(user_id: id_aux).each do |flag|
          flag.destroy
        end
        Notification.where(user_id: id_aux).each do |notification|
          notification.destroy
        end
        Identity.where(user_id: id_aux).each do |identity|
          identity.destroy
        end
        Poll::Question.where(author_id: id_aux).each do |poll|
          poll_question_answers = "delete from poll_question_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_question_answers)
          poll_partial_results = "delete from poll_partial_results where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_partial_results)
          poll_answers = "delete from poll_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_answers)
          poll_questions = "delete from poll_questions where id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_questions)
        end
        Poll::Officer.where(user_id: id_aux).each do |poll|
          poll.destroy
        end
        delete_users = "delete from users where id = #{id_aux}"
        ActiveRecord::Base.connection.execute(delete_users)
        flash[:notice] = t("admin.users.user.successfuly_deleted")
      end
    rescue
      flash[:alert] = t("admin.users.user.no_deleted")
    end
    redirect_to admin_users_path
  end
end
