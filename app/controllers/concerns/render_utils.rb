module RenderUtils
  # Prints the result of apply if enabled
  DEBUG = false

  # If rewards are not specified returns a hash with an object and a message if they are specified
  # If rewards are specified then adds them and returns a hash with the reward with an object and a message if they are specified
  # If no options are specified then returns an empty hash
  # Options and their default values:
  # message: a message to include in the result, none by default
  # object: object to include in the result hash
  # except: fields not to be attached, all included by default
  # Rewards (only if coins or xp are specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def apply(options = {})
    options = parse(options)
    return options unless options.is_a?(Hash)
    result = add_rewards!(options)
    puts result.to_s if DEBUG
    result
  end

  # If rewards are not specified renders a json with an object and a message if they are specified
  # If rewards are specified then adds them and renders a json with the reward with an object and a message if they are specified
  # If no options are specified then renders {}
  # Options and their default values:
  # status: status to render, defaults to :ok
  # message: a message to include in the result, none by default
  # object: object to include in the result, none by default
  # except: fields not to be attached, all included by default
  # Rewards (only if coins or xp are specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def render_from(options = {})
    result = apply(options)
    render json: result, status: get_status(options, :ok)
    result
  end

  # Tries to save the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is saved then adds the rewards
  # and returns a hash with the reward and the object or a message if it is specified
  # If rewards are not specified and the object is saved then returns the object or a message if it is specified
  # Options and their default values:
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp are specified)
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
  # Rewards (only if coins or xp are specified)
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
  # Rewards (only if coins or xp are specified)
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
  # Rewards (only if coins or xp are specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def save_render!(object, options = {})
    result = save!(object, options)
    render json: result, status: get_status(options, :created)
    result
  end

  # Tries to update the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is updated then adds the rewards
  # and renders a json with the reward and the updated object or a message if it is specified
  # If rewards are not specified and the object is updated then renders the updated object or a message if it is specified
  # Options and their default values:
  # status: status to render, defaults to :ok
  # except: fields not to be attached, all included by default
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp are specified)
  # user: @current_user
  # coins: 0
  # xp: 0
  def update_render!(object, fields, options = {})
    result = update!(object, fields, options)
    render json: result, status: get_status(options, :ok)
    result
  end

  # Tries to destroy the object, if fails raises ActiveRecord::RecordInvalid
  # If rewards are specified and the object is destroyed then adds the rewards and renders it
  # If the object is destroyed and nothing is attached to the result then renders head :no_content
  # Otherwise the status is :ok
  # Options and their default values:
  # message: a message to include in the result, none by default
  # Rewards (only if coins or xp are specified)
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
    result
  end

  def fill_defaults(hash, defaults = {})
    defaults.keys.each do |default|
      hash[default] ||= defaults[default]
    end
  end

  def present_all?(hash, keys = [])
    hash.keys.each do |key|
      return false unless keys.include?(key)
    end
    true
  end

  def present_some?(hash, keys = [])
    hash.keys.each do |key|
      return true if keys.include?(key)
    end
    false
  end

  def is_some?(object, classes = [])
    classes.include?(object.class)
  end

  def name(object)
    controller = request.path_parameters[:controller]
    from_controller = from_collection_name?(controller, object)
    plural = collection?(object) && !object.is_a?(Hash)
    name = from_controller ? controller : class_name(object_or_instance(object, plural))
    grammaticalize(name, plural)
  end

  def grammaticalize(name, plural)
    plural ? name.pluralize : name.singularize
  end

  def class_name(object)
    object.class.name.demodulize.parameterize(separator: '_')
  end

  def as_array(object)
    return [] unless object
    object.is_a?(Array) ? object : [object]
  end

  def collection?(object)
    object.respond_to?(:each)
  end

  def empty_collection?(object)
    collection?(object) && object.empty?
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
      before_level = user.level
      user = options[:user]
      user.coins += options[:coins]
      user.xp += options[:xp]
      user.save!
      rewards = {}
      rewards[:coins] = options[:coins] if options[:coins] != 0
      rewards[:xp] = options[:xp] if options[:xp] != 0
      options[:rewards] = rewards
      after_level = user.reload.level
      user.increase_achievements_progress 'level' if before_level < after_level
      user.increase_coins_spent_progress(-1 * options[:coins]) if options[:coins] < 0
    end
    attach_hash(options)
  end

  def merge_object!(hash, object, name = nil)
    unless object.nil?
      object = parse(object, false)
      name ||= name(object)
      key = name.to_sym
      hash[key] = object
      return key
    end
    nil
  end

  def merge!(hash, objects)
    objects.each do |k, v|
      merge_object!(hash, v, k)
    end
  end

  def deep_exclude(object, keys = [])
    return object if keys.empty?
    if object.is_a?(Hash)
      object.inject({}) do |res, (k, v)|
        res[k] = deep_exclude(v, keys) unless keys.include?(k.to_sym)
        res
      end
    elsif object.respond_to?(:attributes)
      result = {}
      parsed = JSON.parse(object.to_json)
      parsed.keys.each do |k|
        result[k] = deep_exclude(parsed[k], keys) unless keys.include?(k.to_sym)
      end
      result
    elsif collection?(object)
      result = []
      object.each do |e|
        result << deep_exclude(e, keys)
      end
      result
    else
      object
    end
  end

  def attach_hash(options = {})
    check_attach!(options[:object], options)
    result = {}
    result[:message] = options[:message] unless options[:message].blank?
    foreign_options = foreign(options)
    key = nil
    if foreign_options.empty? && result.empty?
      result = parse(options[:object]) || {}
    else
      key = merge_object!(result, options[:object])
      merge!(result, foreign_options)
    end
    result = deep_exclude(result, as_array(options[:except]))
    result = result[key] if key && result.is_a?(Hash) && result.size == 1 && result.key?(key) # compact attached object
    result
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

  def object_or_instance(object, plural)
    plural ? object[0] : object
  end

  def from_collection_name?(name, object)
    !name.blank? && (empty_collection?(object) || is_some?(object, [Array, Hash, String]))
  end

  def get_status(options, default)
    return default if options.blank? || !options.respond_to?(:key?) || !options.key?(:status)
    options[:status]
  end

  def parse(object, to_message = true)
    object.is_a?(String) ? from_string(object, to_message) : object
  end

  def from_string(object, to_message = true)
    JSON.parse(object)
  rescue
    to_message ? { message: object } : object
  end

  def foreign(options = {})
    options.except(:object, :message, :user, :coins, :xp, :except, :status) # include rewards
  end

end
