# Crappy hack so we have a simulation of the 'Node' model
# in dradis-pro. (We can't get the real model because dradis-pro
# isn't included as a dependency of this gem.)
#
# For the 'real' set_property method, see dradis-pro/lib/node_properties.rb
class FakeNode
  attr_accessor :properties, :label
  def initialize(attributes={})
    self.label ||= attributes[:label]
  end

  def set_property(key, value)
    @properties ||= {}
    @properties[key.to_sym] = value
  end

  def save!
    @persisted = true
  end

  def persisted?
    @persisted
  end
end

