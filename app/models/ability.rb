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
    
    if user.admin? and user.active?
      
      # Companies
      ############
      can :manage, Company do |company|
        company == user.company
      end
      cannot :index, Company
      
      # Clubs
      ############
      can :manage, Club do |club|
        club.company == user.company
      end
      can :create, :clubs
      
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy.club.company == user.company
      end
      
      # Customers
      ############
      can :manage, Customer do |customer|
        unless customer.company.blank? or customer.company.CompanyNumber == 0
          customer.company == user.company
        else
          true
        end
      end
      can :create, :customers
      
      # Events
      ############
      can :manage, Event do |event|
        unless event.club.blank?
          event.club.company == user.company
        else
          true
        end
      end
      can :create, :events
      
      # Players
      ############
      can :manage, Player do |player|
        player.event.club.company == user.company
      end
      can :create, :players
      
      # Transfers
      ############
      can :manage, Transfer do |transfer|
        unless transfer.player.blank?
          transfer.player.event.club.company == user.company
        else
          transfer.from_account_record.company == user.company
        end
      end
      can :create, :transfers
      
      # CaddyPayRates
      ############
      can :manage, CaddyPayRate do |caddy_pay_rate|
        unless caddy_pay_rate.club.blank?
          caddy_pay_rate.club.company == user.company
        else
          true
        end
      end
      can :create, :caddy_pay_rates
      
      # CaddyRankDescs
      ############
      can :manage, CaddyRankDesc do |caddy_rank_desc|
        unless caddy_rank_desc.club.blank?
          caddy_rank_desc.club.company == user.company
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
          caddy_rating.caddy.club.company == user.company 
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
      
    elsif not user.admin? and user.active?
      # Non-admin, active user
      # 
      # Events
      ############
      can :manage, Event do |event|
        unless event.club.blank?
          event.club.company == user.company
        else
          true
        end
      end
      can :create, :events
      
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy.club.company == user.company
      end
      
      # Customers
      ############
      can :manage, Customer do |customer|
        unless customer.company.blank? or customer.company.CompanyNumber == 0
          customer.company == user.company
        else
          true
        end
      end
      can :create, :customers
    
    end
    
  end
end
