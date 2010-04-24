Secure(User) do |u|
  u.policy(:default) do
    attr_accessible # complete lockdown
  end
  
  u.policy(:self) do
    attr_accessible :name, :email # The user himself can edit name and email
  end
  
  u.policy(:moderator, :include => :self) do
    attr_accessible :notes_attributes 
    # moderators can edit name and email and the nested attribute notes
  end
  
  u.policy(:admin, :include => :moderator) do
    attr_accessible :status # moderators can edit status
  
    validates_exclusion_of :status, :in => [:banned_forever], 
      :unless => :skip_status_validation
      
    def skip_status_validation ; false ; end
    # but the moderator cannot set the status to banned forever
  end
  
  u.policy(:super_admin, :include => :admin) do
    def skip_status_validation ; true ; end 
      # superadmins skip the status validation check
  end
  
  # policies always take precidence over the policies they include.
  # That's why the super-admin policy works.
end