require 'wavefront'
require 'chunky_png'
require_relative 'group'
require_relative 'mtl_loader'

class Model
	attr_accessor :group_list

	def initialize(file, material=nil)
		model = Wavefront::File.new file
		@group_list = []
		@materials = Hash.new
		object = model.object
  		model.object.groups.each do |group|
  			g = Group.new(group, object)
  			@group_list << g
  		end

  		# Cargo los materiales, si es que se pasaron en la lista
  		unless material.nil?
  			mtl_loader = MtlLoader.new(material)
  			mtl_loader.load_material
  			@materials = mtl_loader.materials
  		end
  		
  		# Cargo las imagenes si es que se definieron las texturas en el modelo
  		@materials.each do |k, m|
  			unless m.texture.nil?
  				png = ChunkyPNG::Image.from_file(m.texture)
  				image = png.to_rgba_stream.each_byte.to_a
  				m.texture_image = image.pack("C*")
  				m.texture_width = png.width
  				m.texture_height = png.height
  			end
  		end
	end

	def draw
		@group_list.each do |g|
			material = @materials[g.material]
			unless material.nil?
				glColor3f(material.diffuse.red, material.diffuse.green, material.diffuse.blue)
				glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, [material.specular.red, material.specular.green, material.specular.blue])
				glMaterialf(GL_FRONT, GL_SHININESS, material.shininess)				
				unless material.texture.nil?
					glEnable(GL_TEXTURE_2D)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)  
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)

					glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, material.texture_width, material.texture_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, material.texture_image)
				end
			end
			g.draw
			glDisable(GL_TEXTURE_2D)
		end
	end
end
