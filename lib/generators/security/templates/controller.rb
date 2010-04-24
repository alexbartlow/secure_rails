SecureController(<%= controller.camelize %>) do |<%= controller[0..0].downcase%>|
  <%= controller[0..0].downcase%>.policy(:default) do
    redirect_to 'http://www.youtube.com/watch?v=oHg5SJYRHA0'
    # replace this with your real policy
  end
end