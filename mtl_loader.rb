require_relative 'material'

class MtlLoader
  attr_reader :materials

  def initialize(file_name)
    @materials = Hash.new
    @file_name = file_name
  end

  def load_material
    current_material = nil
    IO.foreach(@file_name) do |line|
      text = line.split
      next if text.length < 1
      case text[0]
        when 'newmtl' then
          current_material = create_material text
        when 'Kd' then
          current_material.diffuse = read_color text
        when 'Ks' then
          current_material.specular = read_color text
        when 'Ns' then
          current_material.shininess = read_shininess text
        when 'map_Kd'
          current_material.texture = text[1]
        when '#', 'Ni', 'd', 'illum', 'Ka', 'Tr', 'Tf', 'map_Ka', 'Ke', 'map_bump', 'bump'

        else
          puts "#{text[0]}: Unknown command"
      end
    end
    puts "Model material #{@file_name} loaded"
  end

  def create_material(line)
    material = Material.new(line[1])
    @materials[line[1]] = material
    material
  end

  def read_color(line)
    color = Color.new
    color.red = line[1].to_f
    color.green = line[2].to_f
    color.blue = line[3].to_f
    color
  end

  def read_shininess(line)
    line[1].to_f
  end
end
