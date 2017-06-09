require_relative 'color'

class Material
	attr_accessor :name, :diffuse, :specular, :shininess, :texture, :texture_image, :texture_width, :texture_height

	def initialize(name)
		@name = name
		@diffuse = Color.new
		@specular = Color.new
		@shinniness = 0.0
		@texture = nil
		@texture_image = nil
	end
end
