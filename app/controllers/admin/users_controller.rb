class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @users = User.by_username_email_or_document_number(params[:search]) if params[:search]
    

    if !params[:hidden_users].blank?  
      @users = @users.where("username LIKE 'Usuario dado de baja-%'")
    else
      @users = @users.where("username NOT LIKE 'Usuario dado de baja-%'")
    end

    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # def destroy
  #   @user.destroy
  #   redirect_to admin_users_path
  # end
  
  def destroy
    begin
      ActiveRecord::Base.transaction do
        Administrator.where(user_id: @user.id).each do |admin|
          admin.destroy
        end
        Proposal.where(author_id: @user.id).each do |proposal|
          proposal.destroy
        end
        Debate.where(author_id: @user.id).each do |debate|
          debate.destroy
        end
        Activity.where(user_id: @user.id).each do |activity|
          activity.destroy
        end
        Budget::Investment.where(author_id: @user.id).each do |b_i|
          b_i.destroy
        end
        Comment.where(user_id: @user.id).each do |comment|
          comment.destroy
        end
        FailedCensusCall.where(user_id: @user.id).each do |call|
          call.destroy
        end
        Valuator.where(user_id: @user.id).each do |valuator|
          valuator.destroy
        end
        DirectMessage.where(sender_id: @user.id).each do |dm|
          dm.destroy
        end
        DirectMessage.where(receiver_id: @user.id).each do |dm|
          dm.destroy
        end
        Moderator.where(user_id: @user.id).each do |valuator|
          valuator.destroy
        end
        Legislation::Answer.where(user_id: @user.id).each do |legis|
          legis.destroy
        end
        Manager.where(user_id: @user.id).each do |valuator|
          valuator.destroy
        end
        Organization.where(user_id: @user.id).each do |org|
          org.destroy
        end
        Follow.where(user_id: @user.id).each do |follow|
          follow.destroy
        end
        Lock.where(user_id: @user.id).each do |lock|
          lock.destroy
        end
        Image.where(user_id: @user.id).each do |image|
          image.destroy
        end
        Flag.where(user_id: @user.id).each do |flag|
          flag.destroy
        end
        Notification.where(user_id: @user.id).each do |notification|
          notification.destroy
        end
        Identity.where(user_id: @user.id).each do |identity|
          identity.destroy
        end
        RelatedContentScore.where(user_id: @user.id).each do |related|
          related.destroy
        end
        Document.where(user_id: @user.id).each do |doc|
          doc.destroy
        end
        Dashboard::AdministratorTask.where(user_id: @user.id).each do |dash|
          dash.destroy
        end
        Poll::Question.where(author_id: @user.id).each do |poll|
          poll_question_answers = "delete from poll_question_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_question_answers)
          poll_partial_results = "delete from poll_partial_results where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_partial_results)
          poll_answers = "delete from poll_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_answers)
          poll_questions = "delete from poll_questions where id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_questions)
        end
        Poll::Officer.where(user_id: @user.id).each do |poll|
          poll.destroy
        end
        delete_users = "delete from users where id = #{@user.id}"
        ActiveRecord::Base.connection.execute(delete_users)
        flash[:notice] = t("admin.users.user.successfuly_deleted")
      end
    rescue
      flash[:alert] = t("admin.users.user.no_deleted")
    end
    redirect_to admin_users_path(hidden_users: true)
  end

  def hide
    
    if !params[:hidden_data].blank?
      user = User.find(params[:id])
      user.username = "Usuario dado de baja-" + user.id.to_s + "-" + params[:hidden_data].to_s
      user.date_hide = Date.today
      user.email = ""
      user.document_number = ""
      user.confirmed_phone = ""
      user.gender = ""
      user.save
      redirect_to admin_users_path, notice: "Usuario #{user.id.to_s} dado de baja." 
    else
      redirect_to admin_users_path, alert: "Debe introducir la causa de la baja para poder eliminar un usuario."
    end
  end
  
  def hide_params
    params.require(:hide).permit(:hidden_datak, :date_hide)
  end
end
