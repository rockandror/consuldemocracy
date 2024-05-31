class Polls::Questions::AnswersComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "polls", "questions", "answers_component").to_s


class Polls::Questions::AnswersComponent < ApplicationComponent
  def open_answer
    if question.answers.nil? || question.answers.empty?
      return ""
    end
    question.answers.by_author(current_user).first.answer
  end

  def info_gender_answer
    if question.answers.by_author(current_user).present?
      return question.answers.by_author(current_user).first.answer
    elsif current_user.gender.present?
      answer = question.find_or_initialize_user_answer(current_user, current_user.gender)
      answer.save_and_record_voter_participation
      return current_user.gender
    end
    return nil
  end

  def info_birthdate
    if question.answers.by_author(current_user).present?
      variable = question.answers.by_author(current_user).first.answer
      return Date.parse(variable)
    elsif current_user.date_of_birth.present?
      birthdate = current_user.date_of_birth
      answer = question.find_or_initialize_user_answer(current_user, birthdate.to_date.strftime('%Y-%m-%d'))
      answer.save_and_record_voter_participation
      return birthdate.to_date
    end
    return nil
  end

  def info_locality
    if question.answers.by_author(current_user).present?
      return question.answers.by_author(current_user).first.answer
    elsif current_user.geozone_id.present?
      answer = question.find_or_initialize_user_answer(current_user, current_user.geozone_id)
      answer.save_and_record_voter_participation
      return current_user.geozone_id
    end
    return nil
  end
end
