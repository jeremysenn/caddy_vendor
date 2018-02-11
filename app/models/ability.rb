class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
       user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    
    if user.is_admin? and user.active?
      ### Active Admin User ###
      
      # Companies
      ############
      can :manage, Company do |company|
        company == user.company
      end
      cannot :index, Company
      
      # Courses
      ############
      can :manage, Course do |course|
        course.company == user.company
      end
      can :create, Course
      
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy.company == user.company
      end
      can :create, Caddy
      
      # Customers
      ############
#      can :manage, Customer do |customer|
#        unless customer.company.blank? or customer.company.CompanyNumber == 0
#          customer.company == user.company
#        else
#          true
#        end
#      end
      can :manage, Customer
      can :create, :customers
      
      # Events
      ############
      can :manage, Event do |event|
        unless event.company.blank?
          event.company == user.company
        else
          true
        end
      end
      can :create, :events
      
      # Players
      ############
      can :manage, Player do |player|
        player.event.company == user.company
      end
      can :create, :players
      
      # Transfers
      ############
      can :manage, Transfer do |transfer|
        transfer.company == user.company
#        unless transfer.player.blank?
#          transfer.player.event.course.company == user.company
#        else
#          unless transfer.customer.blank?
#            transfer.customer.company == user.company
#          else
#            transfer.from_account_record.company == user.company
#          end
#        end
      end
      can :create, :transfers
      
      # CaddyPayRates
      ############
      can :manage, CaddyPayRate do |caddy_pay_rate|
        unless caddy_pay_rate.company.blank?
          caddy_pay_rate.company == user.company
        else
          true
        end
      end
      can :create, :caddy_pay_rates
      
      # CaddyRankDescs
      ############
      can :manage, CaddyRankDesc do |caddy_rank_desc|
        unless caddy_rank_desc.company.blank?
          caddy_rank_desc.company == user.company
        else
          true
        end
      end
      can :create, :caddy_rank_descs
      
      # Transactions
      ############
      can :manage, Transaction do |transaction|
        unless transaction.company.blank?
          transaction.company == user.company 
        else
          true
        end
      end
      
      # CaddyRatings
      ############
      can :manage, CaddyRating do |caddy_rating|
        unless caddy_rating.caddy.blank?
          caddy_rating.caddy.company == user.company 
        else
          true
        end
      end
      can :create, :caddy_ratings
      
      # Users
      ############
      can :manage, User do |user|
        user.company == user.company 
      end
      can :create, :users
      
      # Reports
      ############
      can :index, :reports
      
      # SmsMessages
      ############
      can :manage, SmsMessage do |sms_message|
        sms_message.customer.company == user.company
      end
      can :create, :sms_messages
      can :index, :sms_messages
      
      # VendorPayables
      ############
      can :manage, VendorPayable do |vendor_payable|
        vendor_payable.company == user.company
      end
      
      # Accounts
      ############
      can :manage, Account do |account|
        account.company == user.company 
      end
      
      # BalanceLogs
      ############
      can :manage, BalanceLog do |balance_log|
        balance_log.company == user.company
      end
      can :create, BalanceLog
      
    elsif user.is_caddy? and user.active? and user.phone_verified?
      ### Active Caddy User ###
      
      # Events
      ############
      can :manage, Event do |event|
        user.caddies.each do |caddy|
          if event.include_caddy?(caddy)
            true
          end
        end
#        unless event.course.blank?
#          event.course.company == user.company
#        else
#          true
#        end
      end
      can :create, :events
    
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy == user.caddy or user.caddies.include?(caddy)
      end  
      can :create, Caddy
      cannot :index, Caddy
      
      # Players
      ############
      can :manage, Player do |player|
        # Companies must match, and player caddy must match the currently logged in caddy
#        player.event.course.company == user.company && player.caddy_id == user.caddy.id
        user.caddies.include?(player.caddy)
      end
      
      # Transfers
      ############
      can :manage, Transfer do |transfer|
        # Companies must match, and transfer's player caddy must match the currently logged in caddy
        user.caddies.include?(transfer.caddy)
      end
      can :create, Transfer
      
      # Transactions
      ############
      can :manage, Transaction do |transaction|
        transaction.company == user.company 
      end
      
      # Customers
      ############
      can :create, Customer
      can :manage, Customer do |customer|
        user.caddy_customers.include?(customer)
      end
      cannot :index, Customer
      
      # Users
      ############
      can :manage, User do |user_record|
        user_record == user 
      end
      
    elsif user.is_member? and user.active?
      ###  Active Member User ###  
      
      # Customers
      ############
      can :manage, Customer do |customer|
        customer.company == user.company && customer == user.member
      end
      
      # Transfers
      ############
      can :manage, Transfer do |transfer|
        # Companies must match, and transfer's player caddy must match the currently logged in caddy
        transfer.company == user.company && transfer.player.member_id == user.member.id
      end
      
      # Transactions
      ############
      can :manage, Transaction do |transaction|
        transaction.company == user.company 
      end
      
    elsif not user.is_admin? and user.active? and user.phone_verified?
      ###  Non-admin, active user ### 
      # 
      # Events
      ############
      can :manage, Event do |event|
        unless event.company.blank?
          event.company == user.company
        else
          true
        end
      end
      can :create, :events
      
      # Players
      ############
      can :manage, Player do |player|
        player.event.company == user.company
      end
      can :create, :players
      
      # Transfers
      ############
      can :manage, Transfer do |transfer|
        transfer.company == user.company
      end
      can :create, :transfers
      
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy.company == user.company
      end
      can :index, :caddies
      
      # Customers
      ############
#      can :manage, Customer do |customer|
#        unless customer.company.blank? or customer.company.CompanyNumber == 0
#          customer.company == user.company
#        else
#          true
#        end
#      end
#      can :create, :customers
      
    end
    
  end
end
