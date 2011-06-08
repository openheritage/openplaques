class PlaqueMailer < ActionMailer::Base

  def new_plaque_email(plaque)

    @plaque = plaque

    mail( :from => "notifications@openplaques.org",
          :to => NOTIFICATIONS_EMAIL,
          :subject => "New plaque added to website"
    )
  end


end
