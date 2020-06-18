namespace :legislation_questions do
    desc "Delete multiple answers for questions with limit 1"
    task delete_multiple_answers: :environment do
        Legislation::Question.where(multiple_answers: 1).each do |question|
            query  = "select user_id from legislation_answers where legislation_question_id = #{question.id} group by user_id having count(*) > 1"
            res = ActiveRecord::Base.connection.execute(query)
            res.each do |row|
                row.each do |k,v|
                    puts "==================================="
                    last_answer = Legislation::Answer.where(legislation_question_id: question.id, user_id: v.to_i).order(updated_at: :desc).ids.first
                    delete_query  = "delete from legislation_answers where legislation_question_id = #{question.id} AND user_id = #{v.to_i} AND id != #{last_answer}"
                    ActiveRecord::Base.connection.execute(delete_query)
                    puts "Respuestas actualizadas para el usuario #{v.to_i}"
                    puts "=================================="
                end
            end
        end
    end
  end
  