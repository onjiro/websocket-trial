module JsonSupport 
  def to_json(*a)
    instance_variables.inject({}) { |h, name|
       h.store( name[1..-1], instance_variable_get(name))
       h
    }.to_json(*a)
  end
end
