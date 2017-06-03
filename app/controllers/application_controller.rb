# ApplicationController global controller configurations
class ApplicationController < ActionController::API
  include ExceptionHandler
  include RewardsConstants
  include AuthorizationController

  # Requires authentication token before requesting resources
  # Skip if route does not require Authorization header
  before_action :authenticate_request

  # Checks that update target is the current user unless is admin
  # Skip if route can perform a non-GET method with user_auth_token different than current user
  before_action :verify_user, :verify_issue, :verify_award

  # Checks that params exists and performs security verifications if needed
  # PLEASE, DO NOT SKIP THIS
  before_action :verify_user_auth, :verify_issue_auth, :verify_award_auth

  # If rewards are not specified returns a hash with an object and a message if they are specified
  # If rewards are specified then adds them and returns a hash with the reward with an object and a message if they are specified
  # If no options are specified then returns an empty hash
  # Options and their default values:
  # message: a message to include in the result, none by default
  # object: object to include in the result hash
  # except: fields not to be attached, all included by default
  # Rewards (only if coins or xp specified), none by default
  # user: @current_user
  # coins: 0
  # xp: 0
  def apply(options = {})
    return options unless options.is_a?(Hash)
    add_rewards!(options)
  end

  # If rewards are not specified renders a json with an object and a message if they are specified
  # If rewards are specified then adds them and renders a json with the reward with an object and a message if they are specified
  # If no options are specified then renders {}
  # Options and their default values:
  # status: status to render, defaults to :ok
  # message: a message to include in the result, none by default
  # object: object to include in the result, none by default
  # except: fields not to be attached, all included by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def render_from(options = {})
    render json: apply(options), status: get_status(options, :ok)
  end

  # Tries to save the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is saved then adds the rewards
  # and returns a hash with the reward and the object or a message if it is specified
  # If rewards are not specified and the object is saved then returns the object or a message if it is specified
  # Options and their default values:
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def save!(object, options = {})
    object.save!
    check_attach!(object, options)
    apply(options)
  end

  # Tries to update the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is updated then adds the rewards
  # and returns a hash with the reward and the updated object or a message if it is specified
  # If rewards are not specified and the object is updated then returns the updated object or a message if it is specified
  # Options and their default values:
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def update!(object, fields, options = {})
    object.update!(fields)
    check_attach!(object, options)
    apply(options)
  end

  # Tries to destroy the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is destroyed then adds the rewards
  # and returns a hash with the reward and a message if it is specified
  # If neither rewards nor message are specified and the object is destroyed then returns an empty hash
  # Options and their default values:
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def destroy!(object, options = {})
    object.destroy!
    apply(options.except(:object))
  end

  # Tries to save the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is saved then adds the rewards
  # and renders a json with the reward and the object or a message if it is specified
  # If rewards are not specified and the object is saved then renders the object or a message if it is specified
  # Options and their default values:
  # status: status to render, defaults to :created
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def save_render!(object, options = {})
    render json: save!(object, options), status: get_status(options, :created)
  end

  # Tries to update the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is updated then adds the rewards
  # and renders a json with the reward and the updated object or a message if it is specified
  # If rewards are not specified and the object is updated then renders the updated object or a message if it is specified
  # Options and their default values:
  # status: status to render, defaults to :ok
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def update_render!(object, fields, options = {})
    render json: update!(object, fields, options), status: get_status(options, :ok)
  end

  # Tries to destroy the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is destroyed then adds the rewards and renders it
  # If the object is destroyed and nothing is attached to the result then renders head :no_content
  # Otherwise the status is :ok
  # Options and their default values:
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def destroy_render!(object, options = {})
    result = destroy!(object, options)
    if result.empty?
      head :no_content
    else
      render json: result, status: :ok
    end
  end

  def fill_defaults(hash, defaults = {})
    defaults.keys.each do |default|
      hash[default] ||= defaults[default]
    end
  end

  def present_all?(hash, keys)
    hash.keys.each do |key|
      return false unless keys.include?(key)
    end
    true
  end

  def present_some?(hash, keys)
    hash.keys.each do |key|
      return true if keys.include?(key)
    end
    false
  end

  def name(object)
    plural = collection?(object)
    return request.path_parameters[:controller].to_s if plural && object.empty? && request.path_parameters[:controller]
    instance = plural ? object[0] : object
    name = instance.class.name.demodulize.parameterize(separator: '_')
    name = name.pluralize if plural
    name
  end

  def merge!(hash, object, name = nil)
    name ||= name(object)
    key = name.to_sym
    hash[key] = object if object
    key
  end

  def as_array(object)
    return [] unless object
    object.is_a?(Array) ? object : [object]
  end

  def collection?(object)
    object.is_a?(Array) ||
      object.is_a?(ActiveRecord::Relation) ||
      object.is_a?(ActiveRecord::Associations::CollectionProxy)
  end

  private

  # @see apply(options)
  # Adds a reward to the user and returns a hash with the reward
  # and optionally a message and an attached object
  # Options and their default values: (only if coins or xp specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  # message: a message to include in the result, none by default
  # object: object to include in the result hash, none by default
  # except: fields not to be attached, all included by default
  def add_rewards!(options = {})
    if present_some?(options, [:coins, :xp])
      fill_defaults(options, user: @current_user, coins: 0, xp: 0)
      user = options[:user]
      user.coins += options[:coins]
      user.xp += options[:xp]
      user.save!
      rewards = {}
      rewards[:coins] = options[:coins] if options[:coins] != 0
      rewards[:xp] = options[:xp] if options[:xp] != 0
      options[:rewards] = rewards
    end
    attach_hash(options)
  end

  def attach_hash(options = {})
    result = {}
    result[:message] = options[:message] unless options[:message].blank?
    foreign_options = options.except(:object, :message, :user, :coins, :xp, :except, :status)
    return options[:object] || {} if foreign_options.empty? && result.empty?
    merge!(result, options[:object])
    result.merge!(foreign_options)
    result.except(as_array(options[:except]))
  end

  def check_attach!(object, options = {})
    return unless object
    if include_object?(options)
      options[:object] = object
    else
      options.delete(:object)
    end
  end

  def include_object?(options = {})
    !as_array(options[:except]).include?(:object)
  end

  def get_status(options, default)
    return default unless options[:status]
    options[:status]
  rescue
    default
  end

end
