SecureModel(<%= model.camelize %>) do |<%= model[0..0].downcase%>|
  <%= model[0..0].downcase%>.policy(:default) do
    attr_accessible
    validates_presence_of :id # replace this with your real policy
  end
end