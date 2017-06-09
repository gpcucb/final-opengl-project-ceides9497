class Group
	attr_accessor :vertex_list, :normal_list, :texture_vertex_list, :index_list, :size, :material

	def initialize(group, object)
		triangles = group.triangles
		
		@vertex_list = []
		@texture_vertex_list = []
		@index_list = []
		@normal_list = []
		
		i = 0
		triangles.each do |triangle|
			load_vertex(object, triangle, i, 0)
			@index_list << i
    		i +=  1
    		load_vertex(object, triangle, i, 1)
			@index_list << i
    		i +=  1
    		load_vertex(object, triangle, i, 2)
			@index_list << i
    		i +=  1
		end
		# Esta parte es importante para ganar unos cuantos FPS en ruby
		# Paso los arreglos que estan en alto nivel a una secuencia de 
		# bytes, los cualos son mejor tratados por OpenGL
		@size = @index_list.size
		@vertex_list = @vertex_list.pack("f*")
		@normal_list = @normal_list.pack("f*")
		@texture_vertex_list = @texture_vertex_list.pack("f*")
		@index_list = @index_list.pack("I*")
		@material = group.material
	end

	def draw
		# El dibujado es usando el modelo eficiente, comunicandonos con la tarjeta de video
		glEnableClientState(GL_VERTEX_ARRAY)
		glEnableClientState(GL_NORMAL_ARRAY) if @normal_list.size > 0
		glEnableClientState(GL_TEXTURE_COORD_ARRAY) if @texture_vertex_list.size > 0
		
		glNormalPointer(GL_FLOAT, 0, @normal_list) if @normal_list.size > 0
		glTexCoordPointer(2, GL_FLOAT, 0, @texture_vertex_list) if @texture_vertex_list.size > 0
		glVertexPointer(3, GL_FLOAT, 0, @vertex_list)

		glDrawElements(GL_TRIANGLES, @size, GL_UNSIGNED_INT, @index_list)

		glDisableClientState(GL_VERTEX_ARRAY)
		glDisableClientState(GL_NORMAL_ARRAY) if @normal_list.size > 0
		glDisableClientState(GL_TEXTURE_COORD_ARRAY) if @texture_vertex_list.size > 0
	end

	private
	def load_vertex(object, triangle, i, vertex)
		index = triangle.vertices[vertex].position_index
		# Existen modelos que definen sus indices de forma negativa
		# En estos casos se deja tal cual, en el caso de que sea 
		# mayor a 0 se resta 1
		index -= 1 if index >= 0
		v = object.vertices[index]
		@vertex_list[3 * i] = v.x
		@vertex_list[3 * i + 1] = v.y
		@vertex_list[3 * i + 2] = v.z

		# Cargar las normales, si es que existen
		if (object.normals.size > 0)
			index = triangle.vertices[vertex].normal_index
			index -= 1 if index >= 0
			normal_vertex = object.normals[index]
			@normal_list[3 * i] = normal_vertex.x
	    @normal_list[3 * i + 1] = normal_vertex.y
	    @normal_list[3 * i + 2] = normal_vertex.z
		end
	    
		# Cargar las coordenadas de texture (s, t) si es que existen
		if (object.texture_coordinates.size > 0)
	    index = triangle.vertices[vertex].texture_index
			index -= 1 if index >= 0
			texture_vertex = object.texture_coordinates[index]
			@texture_vertex_list[2 * i] = texture_vertex.x
	    @texture_vertex_list[2 * i + 1] = texture_vertex.y
		end
	end
end
