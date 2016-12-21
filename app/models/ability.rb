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
    
    if user.admin?
      
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
      
      # Caddies
      ############
      can :manage, Caddy do |caddy|
        caddy.club.company == user.company
      end
      
      # Customers
      ############
      can :manage, Customer do |customer|
        customer.company == user.company
      end
      
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
        transfer.player.event.club.company == user.company
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
      
    end
    
  end
end
