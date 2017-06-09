require 'opengl'
require 'glu'
require 'glut'
require 'chunky_png'
require 'wavefront'

require_relative 'model'

include Gl
include Glu
include Glut

FPS = 60.freeze
DELAY_TIME = (1000.0 / FPS)
DELAY_TIME.freeze

def load_objects
  puts "Loading model"
  @endurance = Model.new('obj/endurance', 'obj/endurance.mtl')
  @ranger = Model.new('obj/ranger', 'obj/ranger.mtl')
  @planet = Model.new('obj/saturn', 'obj/saturn.mtl')
  puts "model loaded"
end

def initGL
  glDepthFunc(GL_LEQUAL)
  glEnable(GL_DEPTH_TEST)
  glClearDepth(1.0)

  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  glEnable(GL_LIGHTING)
  glEnable(GL_LIGHT0)
  glEnable(GL_COLOR_MATERIAL)
  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
  glEnable(GL_NORMALIZE)
  glShadeModel(GL_SMOOTH)
  glEnable(GL_CULL_FACE)
  glCullFace(GL_BACK)

  light_position = [0.0, 50.0, 100.0]
  light_color = [1.0, 1.0, 1.0, 1.0]
  specular = [1.0, 1.0, 1.0, 0.0]
  ambient = [0.15, 0.15, 0.15, 1.0]
  glLightfv(GL_LIGHT0, GL_POSITION, light_position)
  glLightfv(GL_LIGHT0, GL_DIFFUSE, light_color)
  glLightfv(GL_LIGHT0, GL_SPECULAR, specular)
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient)
end

def draw
  @frame_start = glutGet(GLUT_ELAPSED_TIME)
  check_fps
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  glPushMatrix
    glTranslate(300.0, -400.0,-300.0)
    glScalef(200.0, 200.0, 200.0)
    @planet.draw
  glPopMatrix

if @up < 30
  glPushMatrix
    glTranslate(0.0, -50.0, -300.0)
    glRotatef(180, 1.0, 0.0, 0.0)
    glRotatef(-@spin, 0.0, 1.0, 0.0)
    glScalef(50.0, 50.0, 50.0)
    @endurance.draw
  glPopMatrix

  if @time > 0
    if @time > 100
      if @up <30
        glPushMatrix
          glTranslate(15.0, -150.0+@up, -300.0)
          glRotatef(45+@time, 0.0, 1.0, 0.0)
          glScalef(10.0, 10.0, 10.0)
          @ranger.draw
        glPopMatrix
      else
        glPushMatrix
          glTranslate(15.0, -120.0, -300.0)
          glRotatef(45+@time, 0.0, 1.0, 0.0)
          glScalef(10.0, 10.0, 10.0)
          @ranger.draw
        glPopMatrix
      end

    else
      glPushMatrix
        glTranslate(15.0, -150.0, -300.0)
        glRotatef(45+@time, 0.0, 1.0, 0.0)
        glScalef(10.0, 10.0, 10.0)
        @ranger.draw
      glPopMatrix
    end

  else
    glPushMatrix
      glTranslate(@time+15.0, -150.0,@time-300.0)
      glRotatef(45.0, 0.0, 1.0, 0.0)
      glScalef(10.0, 10.0, 10.0)
      @ranger.draw
    glPopMatrix
  end
else
  glPushMatrix
    glTranslate(@colision, @colision-50.0,-(@colision) -300.0)
    glRotatef(180, 1.0, 0.0, 0.0)
    glRotatef(-(@spin), 1.0, 1.0, 1.0)
    glScalef(50.0, 50.0, 50.0)
    @endurance.draw
  glPopMatrix

  glPushMatrix
    glTranslate(15.0-@colision, -@colision-120.0, @colision-300.0)
    glRotatef((45+@time), 1.0, 1.0, 1.0)
    glScalef(10.0, 10.0, 10.0)
    @ranger.draw
  glPopMatrix
  @colision = @colision +0.1
end

  glutSwapBuffers
end

def reshape(width, height)
  glViewport(0, 0, width, height)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  gluPerspective(45, (1.0 * width) / height, 0.001, 1000.0)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  gluLookAt(0.0, 50.0, 125.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
end

def idle
    @spin = @spin + 1

    if @spin > 360.0
      @spin = @spin - 360.0
    end

  @time = @time + 1
  if @time > 100
    @up = @up + 0.1
  end

  @frame_time = glutGet(GLUT_ELAPSED_TIME) - @frame_start

  if (@frame_time< DELAY_TIME)
    sleep((DELAY_TIME - @frame_time) / 1000.0)
  end
  glutPostRedisplay
end

def check_fps
  current_time = glutGet(GLUT_ELAPSED_TIME)
  delta_time = current_time - @previous_time

  @frame_count += 1

  if (delta_time > 1000)
    fps = @frame_count / (delta_time / 1000.0)
    puts "FPS: #{fps}"
    @frame_count = 0
    @previous_time = current_time
  end
end

@spin = 0.0
@previous_time = 0
@frame_count = 0
@time = -300.0
@up = 0
@colision = 1

#PlaySound("music/notTimeForCaution.mp3", NULL, SND_ASYNC|SND_FILENAME|SND_LOOP)
load_objects
glutInit
glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
glutInitWindowSize(800,600)
glutInitWindowPosition(10,10)
glutCreateWindow("Hola OpenGL, en Ruby")
glutDisplayFunc :draw
glutReshapeFunc :reshape
glutIdleFunc :idle
initGL
glutMainLoop
