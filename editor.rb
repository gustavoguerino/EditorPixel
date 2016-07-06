$LOAD_PATH << '.'
require 'gosu'

def limpartela(linhas)
	for x in 0..linhas do 
		puts " "
	end
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
				corcarrega = Gosu::Color.rgba(red,green,blue,255)
				valorx = (pixel/4) % $pixellargura
				valory = (pixel/4) / $pixellargura
				$arraycor[valorx.to_i][valory.to_i] = corcarrega
			end
		end
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
$maxlargura = 900.0
class Interface < Gosu::Window
	def initialize 
		super(1000,800,false)
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
		$pincel = 1
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
			draw_quad 								10, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
													10, 			anterior+50, 		@coreditavel[w],			# Superior Direito
													45, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
													45, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
			anterior += 60	
		end	
		anterior = 10
		for w in 12..23
			draw_quad 								55, 			anterior, 			@coreditavel[w], 		# Superior Esquerdo
													55, 			anterior+50, 		@coreditavel[w],			# Superior Direito
													90, 			anterior+50, 		@coreditavel[w],			#	Inferior Esquerdo
													90, 			anterior, 			@coreditavel[w], 6		#	Inferior Direito
			anterior += 60	
		end						
		draw_quad 								9, 				anterior, 				@corcontorno, 		# Superior Esquerdo
												9, 			anterior+60, 			@corcontorno,			# Superior Direito
												90, 			anterior+60, 			@corcontorno,			#	Inferior Esquerdo
												90, 			anterior, 				@corcontorno, 7		#	Inferior Direito	
												
		draw_quad 								11, 			anterior+1, 				@corgerar, 		# Superior Esquerdo
												11, 			anterior+59, 			@corgerar,			# Superior Direito
												89, 			anterior+59, 			@corgerar,			#	Inferior Esquerdo
												89, 			anterior+1, 				@corgerar, 8		#	Inferior Direito	
		@font.draw("Gerar!", 25,anterior+20, 9, 1.0, 1.0, 0xffffffff)

		draw_quad 								910, 			730, 				@corcontorno, 		# Superior Esquerdo
												910, 			790, 			@corcontorno,			# Superior Direito
												990, 			730, 			@corcontorno,			#	Inferior Esquerdo
												990, 			790, 				@corcontorno, 7		#	Inferior Direito	
												
		draw_quad 								911, 			731, 				@corgerar, 		# Superior Esquerdo
												911, 			789, 			@corgerar,			# Superior Direito
												989, 			731, 			@corgerar,			#	Inferior Esquerdo
												989, 			789, 				@corgerar, 8		#	Inferior Direito	
		@font.draw("Limpar!", 918,750, 9, 1.0, 1.0, 0xffffffff)

		
		draw_quad 								920, 			30, 				@corcontorno, 		# Superior Esquerdo
												980, 			30, 				@corcontorno,			# Superior Direito
												980, 			60, 				@corcontorno,			#	Inferior Esquerdo
												920, 			60, 				@corcontorno, 7		#	Inferior Direito	
		draw_quad 								920, 			70, 				@corcontorno, 		# Superior Esquerdo
												980, 			70, 				@corcontorno,			# Superior Direito
												980, 			100, 				@corcontorno,			#	Inferior Esquerdo
												920, 			100, 				@corcontorno, 7		#	Inferior Direito	
		@font.draw("2px", 925,40, 9, 1.0, 1.0, 0xff000000)	
		@font.draw("3px", 925,80, 9, 1.0, 1.0, 0xff000000)			
		for x in 0..$pixellargura-1 do
			for y in 0..$pixelaltura-1 do
							tex = x * $tamanhopixel + 100
							tey = y * $tamanhopixel
						
							tex2 = tex + $tamanhopixel
							tey2 = tey + $tamanhopixel
							draw_quad 		tex, 			tey, 		$arraycor[x][y], 			# Superior Esquerdo
											tex, 			tey2, 		$arraycor[x][y],			# Superior Direito
											tex2, 			tey2, 		$arraycor[x][y],			#	Inferior Esquerdo
											tex2, 			tey, 		$arraycor[x][y], 6		#	Inferior Direito
			end	
		end
	end 

	def update 
		if button_down? Gosu::MsRight then
			pixy = self.mouse_y/$tamanhopixel
			pixx = (self.mouse_x-100)/$tamanhopixel
			if((self.mouse_y >= 0) and (self.mouse_y <= $maxlargura) and (self.mouse_x >= 100) and (self.mouse_x <= $maxlargura))
				if((pixy < $pixelaltura) and (pixx < $pixellargura))
					if($pincel == 1)
						$arraycor[pixx][pixy] = @cortransparente
					elsif($pincel == 2)
						if(pixx+1 <= $pixelaltura)
							$arraycor[pixx][pixy] = @cortransparente
							$arraycor[pixx+1][pixy] = @cortransparente
							if(pixy+1 <= $pixelaltura)
								$arraycor[pixx][pixy+1] = @cortransparente
								$arraycor[pixx+1][pixy+1] = @cortransparente
							end
						else
							$arraycor[pixx][pixy] = @cortransparente
							if(pixy+1 < $pixelaltura)
								$arraycor[pixx][pixy+1] = @cortransparente
							end						
						end
					elsif($pincel == 3)
						if(pixx+1 <= $pixelaltura)	# >>
							$arraycor[pixx][pixy] = @cortransparente
							$arraycor[pixx+1][pixy] = @cortransparente
							if(pixy+1 <= $pixelaltura)
								$arraycor[pixx][pixy+1] = @cortransparente
								$arraycor[pixx+1][pixy+1] = @cortransparente
							end
							if(pixy-1 >= 0)
								$arraycor[pixx][pixy-1] = @cortransparente
								$arraycor[pixx+1][pixy-1] = @cortransparente
							end
							if(pixx-1 >= 0)
								$arraycor[pixx-1][pixy] = @cortransparente
								if(pixy+1 <= $pixelaltura)
									$arraycor[pixx-1][pixy+1] = @cortransparente
								end
								if(pixy-1 >= 0)
									$arraycor[pixx-1][pixy-1] = @cortransparente
								end
							end
						else
							$arraycor[pixx][pixy] = @cortransparente
							if(pixy+1 < $pixelaltura)
								$arraycor[pixx][pixy+1] = @cortransparente
							end			
							if(pixy-1 >= 0)
								$arraycor[pixx][pixy-1] = @cortransparente
							end							
						end
					end
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
			if((self.mouse_y >= 730) and (self.mouse_y <= 790) and (self.mouse_x >= 909) and (self.mouse_x <= 990))
				for x in 0..$pixellargura-1 do
					$arraycor << []
					for y in 0..$pixelaltura-1 do
						$arraycor[x][y] = @cortransparente
					end
				end
			end
			if((self.mouse_y >= 0) and (self.mouse_y <= $maxlargura) and (self.mouse_x >= 900) and (self.mouse_x <= 1000))
				if((self.mouse_x >= 900) and (self.mouse_x <= 1000) and (self.mouse_y >= 30) and (self.mouse_y <= 60))
					puts "Pincel 2px"
					$pincel = 2
				end	
				if((self.mouse_x >= 900) and (self.mouse_x <= 1000) and (self.mouse_y >= 70) and (self.mouse_y <= 100))
					puts "Pincel 3px"
					$pincel = 3
				end	
			end
			if((self.mouse_y >= 0) and (self.mouse_y <= $maxlargura) and (self.mouse_x >= 0) and (self.mouse_x <= 100))
				if((self.mouse_x >= 10) and (self.mouse_x <= 90) and (self.mouse_y >= 730) and (self.mouse_y <= 785))
					puts "Codigo Gerado"
					gerarCodigo()
				end		
				for w in 0..23
					if((self.mouse_x >= 10+acr) and (self.mouse_x <= 45+acr) and (self.mouse_y >= anterior) and (self.mouse_y <= anterior+50))
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
			pixy = (self.mouse_y)/$tamanhopixel
			pixx = (self.mouse_x-100)/$tamanhopixel 
			if((self.mouse_y >= 0) and (self.mouse_y <= $maxlargura) and (self.mouse_x >= 100) and (self.mouse_x <= $maxlargura))				
				if((pixy < $pixelaltura) and (pixx < $pixellargura))
					if($pincel == 1)
						$arraycor[pixx][pixy] = @coreditavel[@idcor]
					elsif($pincel == 2)
						if(pixx+1 <= $pixelaltura)
							$arraycor[pixx][pixy] = @coreditavel[@idcor]
							$arraycor[pixx+1][pixy] = @coreditavel[@idcor]
							if(pixy+1 <= $pixelaltura)
								$arraycor[pixx][pixy+1] = @coreditavel[@idcor]
								$arraycor[pixx+1][pixy+1] = @coreditavel[@idcor]
							end
						else
							$arraycor[pixx][pixy] = @coreditavel[@idcor]
							if(pixy+1 < $pixelaltura)
								$arraycor[pixx][pixy+1] = @coreditavel[@idcor]
							end						
						end
					elsif($pincel == 3)
						if(pixx+1 <= $pixelaltura)	# >>
							$arraycor[pixx][pixy] = @coreditavel[@idcor]
							$arraycor[pixx+1][pixy] = @coreditavel[@idcor]
							if(pixy+1 <= $pixelaltura)
								$arraycor[pixx][pixy+1] = @coreditavel[@idcor]
								$arraycor[pixx+1][pixy+1] = @coreditavel[@idcor]
							end
							if(pixy-1 >= 0)
								$arraycor[pixx][pixy-1] = @coreditavel[@idcor]
								$arraycor[pixx+1][pixy-1] = @coreditavel[@idcor]
							end
							if(pixx-1 >= 0)
								$arraycor[pixx-1][pixy] = @coreditavel[@idcor]
								if(pixy+1 <= $pixelaltura)
									$arraycor[pixx-1][pixy+1] = @coreditavel[@idcor]
								end
								if(pixy-1 >= 0)
									$arraycor[pixx-1][pixy-1] = @coreditavel[@idcor]
								end
							end
						else
							$arraycor[pixx][pixy] = @coreditavel[@idcor]
							if(pixy+1 < $pixelaltura)
								$arraycor[pixx][pixy+1] = @coreditavel[@idcor]
							end			
							if(pixy-1 >= 0)
								$arraycor[pixx][pixy-1] = @coreditavel[@idcor]
							end							
						end
					end
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
def carregarConfigs()
	arrayleitura = File.readlines("configs.txt")
	for z in arrayleitura do
		dividivoconf = z.split(" ")
		if(dividivoconf[0] == "LarguraXAltura=")
		$largura = dividivoconf[1].to_i
		$altura = dividivoconf[1].to_i
		elsif(dividivoconf[0] == "TamanhoDoPixel=")
		$tpixel = dividivoconf[1].to_i
		end
	end	
	if(($tpixel != 1) and ($tpixel != 2) and ($tpixel != 4) and ($tpixel != 8) and ($tpixel != 16) and ($tpixel != 32))
	elsif(($largura != 64) and ($largura != 128) and ($largura != 256) and ($largura != 512) and ($largura != 1024))
	else
		$pixelaltura = $altura / $tpixel
		$pixellargura = $largura / $tpixel
		if($altura >= $largura)
			$tamanhopixel = 800.0 / $pixelaltura
		else
			$maxlargura = 1200.0
			$tamanhopixel = $maxlargura-100 / $pixellargura
		end
		Interface.new.show
	end
end
carregarConfigs()
