$LOAD_PATH << '.'
require 'gosu'

def limpartela(linhas)
	for x in 0..linhas do 
		puts " "
	end
end
def gerarCodigo()
	arq = File.new("saida.txt", "w")
	arq.puts "desenhar:\n	lui $9, 0x1001\n	"
	contavazios = 0
	coranterior = 0
	for y in 0..$pixellargura-1 do
		for x in 0..$pixelaltura-1 do
			if($arraycor[x][y] == @cortransparente)
				contavazios += 1
			else
				if(contavazios != 0)
					arq.puts "	addi $9, $9, #{contavazios*4} \n "
					contavazios = 0
				end
				if(coranterior != $arraycor[x][y])
					arq.puts "	addi $10, $0, 0x#{"%02x" % $arraycor[x][y].red}#{"%02x" % $arraycor[x][y].green}#{"%02x" % $arraycor[x][y].blue}\n"
				end
				arq.puts "	sw $10, 0($9)\n"
				coranterior = $arraycor[x][y]
				contavazios += 1
			end
		end
	end
	arq.close
end
entrada = 0
while ((entrada != 1) and (entrada != 2) and (entrada != 4) and (entrada != 8) and (entrada != 16) and (entrada != 32))
	limpartela(40)
	puts "Para iniciar preciso de alguns detalhes!\nQual tamanho dos pixels usados no Bit Map Display (Unit Height and Width) \n Responda 1, 2, 4, 8, 16 ou 32 pixels: \n"
	entrada = gets.to_f
end
$pixels = entrada

entrada = 0
while ((entrada != 64) and (entrada != 128) and (entrada != 256) and (entrada != 512) and (entrada != 1024))
	limpartela(40)
	puts "Certo!\nAgora, qual a largura em pixels do display ? (Display Width) \n Responda 64, 128, 256, 512 ou 1024 pixels: \n"
	entrada = gets.to_f
end
$largura = entrada

entrada = 0
while ((entrada != 64) and (entrada != 128) and (entrada != 256) and (entrada != 512) and (entrada != 1024))
	limpartela(40)
	puts "Certo!\nAgora, qual a altura em pixels do display ? (Display Height) \n Responda 64, 128, 256, 512 ou 1024 pixels: \n"
	entrada = gets.to_f
end
$altura = entrada
$pixelaltura = $altura / $pixels
$pixellargura = $largura / $pixels
if($altura > $largura)
	$tamanhopixel = 800.0 / $pixelaltura
else
	$tamanhopixel = 800.0 / $pixellargura
end
def carregarCodigo()
	arrayleitura = File.readlines("saida.txt")
	pixel = 0
	corcarrega = Gosu::Color.rgba(255,255,255,255)
	for z in arrayleitura do
		arraydalinha = z.split(" ")
		@redrawn = true
		if(arraydalinha.size > 0)
			if((arraydalinha[0] == "addi") and (arraydalinha[1] == "$9,"))
				pixel += arraydalinha[3].to_i
			elsif((arraydalinha[0] == "addi") and (arraydalinha[1] == "$10,"))#0x871a13 passa a cor.. converter para decimal. .to_i(16)
				red =  arraydalinha[3][2] + arraydalinha[3][3]
				green =  arraydalinha[3][4] + arraydalinha[3][5]
				blue =  arraydalinha[3][6] + arraydalinha[3][7]
				red = red.to_i(16)
				green = green.to_i(16)
				blue = blue.to_i(16)
				corcarrega = Gosu::Color.rgba(red,green,blue,255)
			elsif(arraydalinha[0] == "sw")
				$arraycor[(pixel / $pixellargura)][(pixel % $pixellargura)] = corcarrega
			end
		end
	end
end
class Interface < Gosu::Window
	def initialize 
		super(900,800,false)
		self.caption = "Editor Pixel Mars Mips"
		@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
		$arraycor = []
		@cortransparente = Gosu::Color.rgba(255,0,255,200)
		for x in 0..$pixellargura-1 do
			$arraycor << []
			for y in 0..$pixelaltura-1 do
				$arraycor[x][y] = @cortransparente
			end
		end
		@coreditavel = []
		selectcores = 0
		@idcor = 1
		arraylinhas = File.readlines("coresentrada.txt")

		@corgerar = Gosu::Color.rgba(0,0,0,255)
		@corcontorno = Gosu::Color.rgba(255,255,255,255)
		for z in arraylinhas do
			arraylinha = z.split(",")
			if arraylinha.size == 3
				red  = arraylinha[0].to_i
				green  = arraylinha[1].to_i
				blue  = arraylinha[2].to_i
				@coreditavel[selectcores] = Gosu::Color.rgba(red,green,blue,255)
				selectcores += 1
			end
			if arraylinha.size == 4
				red  = arraylinha[0].to_i
				green  = arraylinha[1].to_i
				blue  = arraylinha[2].to_i
				transparencia  = arraylinha[3].to_i
				@cortransparente = Gosu::Color.rgba(red,green,blue,transparencia)
			end
		end
		carregarCodigo()
	end 
 
	def draw
		anterior = 10
		for w in 0..11
			draw_quad 						810, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
													810, 			anterior+50, 		@coreditavel[w],			# Superior Direito
													845, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
													845, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
			anterior += 60	
		end	
		anterior = 10
		for w in 12..23
			draw_quad 						855, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
													855, 			anterior+50, 		@coreditavel[w],			# Superior Direito
													890, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
													890, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
			anterior += 60	
		end						
		draw_quad 						810, 			anterior, 				@corcontorno, 		# Superior Esquerdo
												810, 			anterior+60, 			@corcontorno,			# Superior Direito
												890, 			anterior+60, 			@corcontorno,			#	Inferior Esquerdo
												890, 			anterior, 				@corcontorno, 7		#	Inferior Direito	
												
		draw_quad 						811, 			anterior+1, 				@corgerar, 		# Superior Esquerdo
												811, 			anterior+59, 			@corgerar,			# Superior Direito
												889, 			anterior+59, 			@corgerar,			#	Inferior Esquerdo
												889, 			anterior+1, 				@corgerar, 8		#	Inferior Direito	
		@font.draw("Gerar!", 825,anterior+20, 9, 1.0, 1.0, 0xffffffff)
												
		for x in 0..$pixellargura-1 do
			for y in 0..$pixelaltura-1 do
							tex = x * $tamanhopixel
							tey = y * $tamanhopixel
							tex2 = tex + $tamanhopixel
							tey2 = tey + $tamanhopixel
							draw_quad 		tex, 			tey, 			$arraycor[x][y], 			# Superior Esquerdo
													tex, 			tey2, 		$arraycor[x][y],			# Superior Direito
													tex2, 		tey2, 		$arraycor[x][y],			#	Inferior Esquerdo
													tex2, 		tey, 			$arraycor[x][y], 6		#	Inferior Direito
			end	
		end
	end 

	def update 
		if button_down? Gosu::MsRight then
			pixy = self.mouse_y/$tamanhopixel
			pixx = self.mouse_x/$tamanhopixel
			if((self.mouse_y >= 0) and (self.mouse_y <= 800) and (self.mouse_x >= 0) and (self.mouse_x <= 800))
				if((pixy < $pixelaltura) and (pixx < $pixellargura))
					$arraycor[pixx][pixy] = @cortransparente
				end
			end		
		end
		if button_down? Gosu::MsLeft then
		
			#draw_quad 						810, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
				#									810, 			anterior+50, 		@coreditavel[w],			# Superior Direito
					#								845, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
						#							845, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
						
			#draw_quad 						855, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
				#									855, 			anterior+50, 		@coreditavel[w],			# Superior Direito
					#								890, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
						#							890, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
			anterior = 10
			contacor = 0
			acr = 0
			if((self.mouse_y >= 0) and (self.mouse_y <= 800) and (self.mouse_x >= 800) and (self.mouse_x <= 900))
				if((self.mouse_x >= 810) and (self.mouse_x <= 890) and (self.mouse_y >= 730) and (self.mouse_y <= 785))
					puts "Codigo Gerado"
					gerarCodigo()
				end		
				for w in 0..23
					if((self.mouse_x >= 810+acr) and (self.mouse_x <= 845+acr) and (self.mouse_y >= anterior) and (self.mouse_y <= anterior+50))
						@idcor = w
						puts "Cor #{w} Selecionada"
					end
					if(w == 11)
						anterior = 10
						acr = 45
					else
						anterior += 60
					end
				end
			end
			pixy = self.mouse_y/$tamanhopixel
			pixx = self.mouse_x/$tamanhopixel
			if((self.mouse_y >= 0) and (self.mouse_y <= 800) and (self.mouse_x >= 0) and (self.mouse_x <= 800))
				if((pixy < $pixelaltura) and (pixx < $pixellargura))
					$arraycor[pixx][pixy] = @coreditavel[@idcor]
					@redrawn = true
				end
			end
		end
	end
	def needs_cursor?
		true
	end
	def needs_redraw?
		if(@redrawn == true)
			true
		else
			false
		end
	end
end

Interface.new.show