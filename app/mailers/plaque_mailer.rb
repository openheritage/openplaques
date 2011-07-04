class PlaqueMailer < ActionMailer::Base

  def new_plaque_email(plaque)

    @plaque = plaque

    mail( :from => "notifications@openplaques.org",
          :to => NOTIFICATIONS_EMAIL,
          :subject => ""  # For some reason, having this non-blank results in: undefined method `encode!'
    )
  end


end
