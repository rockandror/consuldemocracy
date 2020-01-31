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
        Follow.where(user_id: @user.id).each do |org|
          org.destroy
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
    redirect_to admin_users_path
  end
end
