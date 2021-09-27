-- Listing 13.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity pong_graph is
   port(
      clk, reset: std_logic;
      btn: std_logic_vector(3 downto 0);
		shoot: std_logic; --switch1
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      gra_still, rst_enemy: in std_logic;
      graph_on, hit, miss: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end pong_graph;

architecture arch of pong_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
	signal btn_reg, btn_next: std_logic_vector(3 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
	
	signal shot_next,shot_reg: std_logic := '0';
   
	constant WALL_X_L_L: integer:=0;
   constant WALL_X_R_L: integer:=8;
	constant WALL_X_L_R: integer:=630;
   constant WALL_X_R_R: integer:=640;
	
	constant WALL_Y_T_T: integer:=0;
	constant WALL_Y_B_T: integer:=8;
	constant WALL_Y_T_B: integer:=456-9;
	constant WALL_Y_B_B: integer:=480;
	
   signal bar_y_t, bar_y_b, bar_x_r, bar_x_l: unsigned(9 downto 0);
   constant BAR_Y_SIZE: integer:=32;
	constant BAR_X_Size: integer:=32;
   signal bar_y_reg, bar_y_next: unsigned(9 downto 0);
	signal bar_x_reg, bar_x_next: unsigned(9 downto 0);
   constant BAR_V: integer:=2;
   constant BALL_SIZE: integer:=8; -- 8
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
   signal ball_vx_reg, ball_vx_next: unsigned(9 downto 0);
   signal ball_vy_reg, ball_vy_next: unsigned(9 downto 0);
   constant BALL_V_P: unsigned(9 downto 0)
            :=to_unsigned(3,10);
   constant BALL_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-3,10));
	constant BALL_V_Z: unsigned(9 downto 0)
            :=unsigned(to_signed(0,10));
				
				
				
	constant ENEMY_Y_SIZE: integer:=32;
	constant ENEMY_X_SIZE: integer:=32;	
   signal enemy_x_l, enemy_x_r: unsigned(9 downto 0);
   signal enemy_y_t, enemy_y_b: unsigned(9 downto 0);
   signal enemy_x_reg, enemy_x_next: unsigned(9 downto 0);
   signal enemy_y_reg, enemy_y_next: unsigned(9 downto 0);
   signal enemy_vx_reg, enemy_vx_next: unsigned(9 downto 0);
   signal enemy_vy_reg, enemy_vy_next: unsigned(9 downto 0);
   constant ENEMY_V_P: unsigned(9 downto 0)
            :=to_unsigned(1,10);
   constant ENEMY_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-1,10));
	constant ENEMY_V_Z: unsigned(9 downto 0)
            :=unsigned(to_signed(0,10));
				
--BULLET-----------------------------------------------------------
   type rom_type is array (0 to 7) of
        std_logic_vector (7 downto 0);
   constant BALL_ROM: rom_type :=
   (
      "00000000", --   ****
      "00111100", --  ******
      "01111110", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", -- ********
      "00111100", --  ******
      "00000000"  --   ****
   );
-------------------------------------------------------------------
	type rom_type_2 is array (0 to 15,0 to 15) of
        std_logic_vector (2 downto 0);
	constant PLAYER_ROM: rom_type_2 :=
   (
      ("000","000", "000", "000", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000"),
		("000","000", "000", "001", "110", "110", "110", "110", "110", "110", "001", "000", "000", "000", "000", "000"),
		("000","000", "001", "110", "001", "110", "110", "110", "110", "001", "110", "001", "000", "000", "000", "000"),
		("000","000", "001", "110", "110", "110", "110", "110", "110", "110", "110", "001", "000", "000", "000", "000"),
		("000","000", "001", "110", "110", "011", "011", "011", "011", "110", "110", "001", "000", "000", "000", "000"),
		("000","000", "000", "110", "110", "011", "011", "011", "011", "110", "110", "000", "000", "000", "000", "000"),
		("000","000", "000", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "010", "010", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","001", "001", "001", "001", "110", "010", "010", "110", "001", "001", "001", "001", "000", "000", "000"),
		("000","001", "001", "001", "001", "110", "110", "110", "110", "001", "001", "001", "001", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "000", "100", "100", "100", "000", "000", "100", "100", "100", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "000", "000", "000", "000"),
		("000","001", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "001", "000", "000", "000")
   );
	
	constant PLAYER_ROM_SIDE: rom_type_2 :=
   (
      ("000","000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "001", "001", "001", "110", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "001", "001", "001", "001", "110", "110", "001", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "110", "110", "001", "110", "110", "110", "110", "001", "000", "000", "000", "000"),
		("000","000", "001", "110", "110", "110", "110", "110", "110", "011", "011", "001", "000", "000", "000", "000"),
		("000","000", "000", "110", "110", "110", "110", "110", "110", "011", "011", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "010", "010", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "110", "010", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "001", "001", "110", "110", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "000", "001", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000", "000"),
		("000","000", "000", "001", "001", "100", "000", "000", "100", "100", "000", "000", "000", "000", "000", "000"),
		("000","000", "000", "000", "001", "001", "000", "000", "001", "001", "001", "000", "000", "000", "000", "000"),
		("000","000", "000", "000", "000", "001", "000", "000", "001", "001", "001", "001", "000", "000", "000", "000")
   );
	
	constant PLAYER_ROM_BACK: rom_type_2 :=
   (
      ("000","000", "000", "000", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000"),
		("000","000", "001", "101", "101", "101", "101", "101", "101", "101", "001", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "101", "101", "101", "101", "101", "101", "101", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","000", "000", "110", "110", "110", "110", "110", "110", "110", "110", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "001", "001", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "000", "100", "100", "100", "000", "000", "100", "100", "100", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "000", "000", "000", "000"),
		("000","001", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "001", "000", "000", "000")
   );
    
	--type rom_type_3 is array (0 to 15,0 to 15) of
   --     std_logic_vector (2 downto 0);
	constant ENEMY_ROM: rom_type_2 :=
   (
		("000","000", "000", "000", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000", "000"),
		("000","000", "000", "101", "101", "101", "101", "101", "101", "101", "101", "000", "000", "000", "000", "000"),
		("000","000", "000", "001", "110", "110", "110", "110", "110", "110", "001", "000", "000", "000", "000", "000"),
		("000","000", "001", "110", "001", "110", "110", "110", "110", "001", "110", "001", "000", "000", "000", "000"),
		("000","000", "001", "110", "110", "110", "110", "110", "110", "110", "110", "001", "000", "000", "000", "000"),
		("000","000", "001", "110", "100", "101", "100", "100", "101", "100", "110", "001", "000", "000", "000", "000"),
		("000","000", "000", "110", "110", "100", "100", "100", "100", "110", "110", "000", "000", "000", "000", "000"),
		("000","000", "000", "001", "001", "100", "001", "001", "001", "001", "001", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "001", "010", "010", "001", "001", "001", "001", "000", "000", "000", "000"),
		("000","001", "001", "001", "001", "110", "010", "010", "110", "001", "001", "001", "001", "000", "000", "000"),
		("000","001", "001", "001", "001", "110", "110", "110", "110", "001", "001", "001", "001", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "100", "100", "100", "100", "100", "100", "100", "100", "100", "100", "000", "000", "000", "000"),
		("000","000", "000", "100", "100", "100", "000", "000", "100", "100", "100", "000", "000", "000", "000", "000"),
		("000","000", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "000", "000", "000", "000"),
		("000","001", "001", "001", "001", "000", "000", "000", "000", "001", "001", "001", "001", "000", "000", "000")
   );

	
   
	signal rom_addr_player, rom_col_player: unsigned(3 downto 0);
	signal rom_bit_player,rom_next_player: std_logic_vector(2 downto 0);
	signal rom_data_player: std_logic_vector(7 downto 0);
	
	signal rom_addr_enemy, rom_col_enemy: unsigned(3 downto 0);
	signal rom_bit_enemy, rom_next_enemy: std_logic_vector(2 downto 0);
	signal rom_data_enemy: std_logic_vector(7 downto 0);
	
	signal rom_addr, rom_col: unsigned(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);
   signal rom_bit: std_logic;
   signal wall_on, sq_ball_on, rd_ball_on, player_on, enemy_on: std_logic;

   signal wall_rgb, player_rgb, ball_rgb, enemy_rgb:std_logic_vector(2 downto 0);
   signal refr_tick: std_logic;
	
begin

   -- REGISTERS----------------------------------------------------------------------
   process (clk,reset)
   begin
      if reset='1' then
		
         bar_y_reg <= (OTHERS=>'0');
			bar_x_reg <= (OTHERS=>'0');
         
			ball_x_reg <= (OTHERS=>'0');
         ball_y_reg <= (OTHERS=>'0');
         ball_vx_reg <= ("0000000100");
         ball_vy_reg <= ("0000000100");
			
			enemy_x_reg <= (OTHERS=>'0');
         enemy_y_reg <= (OTHERS=>'0');
         enemy_vx_reg <= ("0000000100");
         enemy_vy_reg <= ("0000000100");
			
			shot_reg <= '0';
			rom_bit_player <= (OTHERS=>'0');
			--rom_bit_enemy <= (OTHERS => '0');
			btn_reg <= (others=>'0');
			
      elsif (clk'event and clk='1') then
		
         bar_y_reg <= bar_y_next;
			bar_x_reg <= bar_x_next;
			
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         ball_vx_reg <= ball_vx_next;
         ball_vy_reg <= ball_vy_next;
			
			enemy_x_reg <= enemy_x_next;
         enemy_y_reg <= enemy_y_next;
         enemy_vx_reg <= enemy_vx_next;
         enemy_vy_reg <= enemy_vy_next;
			
			shot_reg <= shot_next;
			rom_bit_player <= rom_next_player;
			btn_reg <= btn_next;
			--rom_bit_enemy <= rom_next_enemy;
			
      end if;
   end process;
	
	----------------------------------------------------------------------------------------
	
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
   -- wall
   wall_on <=
      '1' when 	((WALL_X_L_L<=pix_x) and (pix_x<=WALL_X_R_L))
					or ((WALL_X_L_R<=pix_x) and (pix_x<=WALL_X_R_R))
					or ((WALL_Y_T_T<=pix_y) and (pix_y<=WALL_Y_B_T))
					or ((WALL_Y_T_B<=pix_y) and (pix_y<=WALL_Y_B_B))
					else
      '0';
   wall_rgb <= "001"; -- blue
	
	
	-- PLAYER----------------------------------------------------------------------------------------
	
	rom_addr_player <= pix_y(4 downto 1) - bar_y_t(4 downto 1);
   rom_col_player <= pix_x(4 downto 1) - bar_x_l(4 downto 1);
	
	process(btn)
   begin
		rom_next_player <= rom_bit_player;
      if gra_still='1' then  --initial position of paddle
			rom_next_player <= PLAYER_ROM(to_integer(rom_addr_player), to_integer(rom_col_player));
      else
         if btn(1)='1'  then
				btn_next <= "0010";
				rom_next_player <= PLAYER_ROM(to_integer(rom_addr_player), to_integer(rom_col_player));
         elsif btn(0)='1'  then
				btn_next <= "0001";
				rom_next_player <= PLAYER_ROM_BACK(to_integer(rom_addr_player), to_integer(rom_col_player));
			elsif btn(2)='1'  then
				btn_next <= "0100";
				rom_next_player <= PLAYER_ROM_SIDE(to_integer(rom_addr_player), to_integer(rom_col_player));
			elsif btn(3)='1'  then
				btn_next <= "1000";
				rom_next_player <= PLAYER_ROM_SIDE(to_integer(rom_addr_player), to_integer(not rom_col_player));	
			else
				--rom_next_player<= PLAYER_ROM(to_integer(rom_addr_player), to_integer(rom_col_player));--rom_next_player <= rom_bit_player;
				if btn_reg(1) ='1' then
					rom_next_player <= PLAYER_ROM(to_integer(rom_addr_player), to_integer(rom_col_player));
				elsif btn_reg(0) ='1' then
					rom_next_player <= PLAYER_ROM_BACK(to_integer(rom_addr_player), to_integer(rom_col_player));
				elsif btn_reg(2) ='1' then
					rom_next_player <= PLAYER_ROM_SIDE(to_integer(rom_addr_player), to_integer(rom_col_player));
				else-- btn_reg(0) ='1' then
					rom_next_player <= PLAYER_ROM_SIDE(to_integer(rom_addr_player), to_integer(not rom_col_player));	
				end if;
         end if;
      end if;
   end process;
	
	
   bar_y_t <= bar_y_reg;
	bar_x_r <= bar_x_reg;
   bar_y_b <= bar_y_t + BAR_Y_SIZE - 1;
	bar_x_l <= bar_x_r + BAR_X_SIZE - 1;
   player_on <=
      '1' when (bar_x_r<=pix_x) and (bar_x_l>=pix_x) and
               (bar_y_t<=pix_y) and (pix_y<=bar_y_b) and (rom_bit_player/="000") else
      '0';
	player_rgb <= rom_bit_player;
	
   -- new player y and x-position
   process(btn,bar_y_reg,bar_y_b,bar_y_t,refr_tick,btn,gra_still,bar_x_reg,bar_x_r, bar_x_l)
   begin
      bar_y_next <= bar_y_reg; -- no move
		bar_x_next <= bar_x_reg; -- no move
      if gra_still='1' then  --initial position of paddle
         bar_y_next <= to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);
			bar_x_next <= to_unsigned((MAX_X-BAR_X_SIZE)-64,10);
      elsif refr_tick='1' then
         if btn(1)='1' and bar_y_b<(WALL_Y_T_B-1-BAR_V) then
            bar_y_next <= bar_y_reg + BAR_V; -- move down
         elsif btn(0)='1' and bar_y_t > (WALL_Y_B_T + BAR_V) then
            bar_y_next <= bar_y_reg - BAR_V; -- move up
			elsif btn(2)='1' and bar_x_l <(WALL_X_L_R - BAR_V - 1) then
            bar_x_next <= bar_x_reg + BAR_V; -- move right
			elsif btn(3)='1' and bar_x_r > (WALL_X_R_L + BAR_V) then
            bar_x_next <= bar_x_reg - BAR_V; -- move left
         end if;
      end if;
   end process;

	--BALL---------------------------------------------------------------------------
	
   -- square ball
   ball_x_l <= --bar_x_reg when SHOT ='0' else
					ball_x_reg; --ball_x_reg;
   ball_y_t <= --bar_y_reg when SHOT = '0' else
					ball_y_reg; --ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE ;
   ball_y_b <= ball_y_t + BALL_SIZE ;
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- round ball
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(not rom_col));
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') and (not player_on='1')else
      '0';
   ball_rgb <= "011";   -- red
   -- new ball position
   ball_x_next <=
      --to_unsigned((MAX_X)/2,10) when SHOT ='0' else
      (bar_x_reg + 8) when shot_next = '0' or rst_enemy ='1' else
		ball_x_reg + ball_vx_reg when refr_tick='1' else
      ball_x_reg ;
   ball_y_next <=
      --to_unsigned((MAX_Y)/2,10) when SHOT ='0' else
      (bar_y_reg + 8) when shot_next = '0' or rst_enemy ='1' else
		ball_y_reg + ball_vy_reg when refr_tick='1' else
      ball_y_reg ;
   -- new ball velocity
   -- wuth new hit, miss signals
	
   process(ball_vx_reg,ball_vy_reg,ball_y_t,ball_x_l,ball_x_r,
           ball_y_t,ball_y_b,bar_y_t,bar_y_b,bar_x_l, bar_x_r)
	begin
      --hit <='0';
      --miss <='0';
		shot_next <= shot_reg;
      ball_vx_next <= ball_vx_reg;
      ball_vy_next <= ball_vy_reg;
      if shoot = '1' and btn_reg(0) ='1' then            --initial velocity
			--UP
         ball_vx_next <= BALL_V_Z;
         ball_vy_next <= BALL_V_N;
			shot_next <= '1';
		elsif shoot = '1' and btn_reg(1) ='1' then            --initial velocity
         --DOWN
			ball_vx_next <= BALL_V_Z;
         ball_vy_next <= BALL_V_P;
			shot_next <= '1';
		elsif shoot = '1' and btn_reg(2) ='1' then            --initial velocity
         --RIGHT
			ball_vx_next <= BALL_V_P;
         ball_vy_next <= BALL_V_Z;
			shot_next <= '1';
		elsif shoot = '1' and btn_reg(3) ='1' then            --initial velocity
         --LEFT
			ball_vx_next <= BALL_V_N;
         ball_vy_next <= BALL_V_Z;
			shot_next <= '1';
      elsif ball_y_t < 1 then          -- reach top
         --ball_vy_next <= BALL_V_P;
			--miss <= '1';
			shot_next <= '0';
      elsif ball_y_b > (WALL_Y_T_B) then  -- reach bottom
         --ball_vy_next <= BALL_V_N;
			--miss <= '1';
			shot_next <= '0';
      elsif ball_x_l < 1 then -- reach left border	WALL_X_R_L
         --ball_vx_next <= BALL_V_P;  
			--miss <= '1';
			shot_next <= '0';	-- bounce back
      --elsif (BAR_X_L<=ball_x_r) and (ball_x_r<=BAR_X_R) and
        --    (bar_y_t<=ball_y_b) and (ball_y_t<=bar_y_b) then
            -- reach x of right bar, a hit
          --  ball_vx_next <= BALL_V_N; -- bounce back
            --hit <= '1';
      elsif (ball_x_r > (WALL_X_L_R)) then     -- reach right border
         --miss <= '1';  
			shot_next <= '0';			-- a miss
      end if;
   end process;
	
	-----------------------------------------------------------------------
	--ENEMY 
	rom_addr_enemy <= pix_y(4 downto 1) - enemy_y_t(4 downto 1);
   rom_col_enemy <= pix_x(4 downto 1) - enemy_x_l(4 downto 1);
   enemy_x_l <= --bar_x_reg when SHOT ='0' else
					enemy_x_reg; --ball_x_reg;
   enemy_y_t <= --bar_y_reg when SHOT = '0' else
					enemy_y_reg; --ball_y_reg;
   enemy_x_r <= enemy_x_l + ENEMY_X_SIZE ;
   enemy_y_b <= enemy_y_t + ENEMY_Y_SIZE ;
	enemy_on <=
      '1' when (enemy_x_l<=pix_x) and (enemy_x_r>=pix_x) and
               (enemy_y_t<=pix_y) and (pix_y<=enemy_y_b) and (rom_bit_enemy/="000") else
      '0';
	rom_bit_enemy <= ENEMY_ROM(to_integer(rom_addr_enemy), to_integer(rom_col_enemy));
	enemy_rgb <= rom_bit_enemy; 
   -- new enemy position
   enemy_x_next <=
      --to_unsigned((MAX_X)/2,10) when SHOT ='0' else
      --bar_x_reg when shot_next = '0' else
		to_unsigned(WALL_X_R_L,10) when gra_still='1' or rst_enemy= '1' else
		enemy_x_reg + enemy_vx_reg when refr_tick='1' else
      enemy_x_reg ;--to_unsigned((MAX_X)/2,10);
   enemy_y_next <=
      --to_unsigned((MAX_Y)/2,10) when SHOT ='0' else
      --enemy_y_reg when shot_next = '0' else
		to_unsigned(WALL_Y_B_T,10) when gra_still='1' or rst_enemy= '1' else
		enemy_y_reg + enemy_vy_reg when refr_tick='1' else
      enemy_y_reg ;--to_unsigned((MAX_Y)/2,10);
		
	process(enemy_vx_reg,enemy_vy_reg,enemy_y_t,enemy_x_l,enemy_x_r,
           enemy_y_t,enemy_y_b,bar_y_t,bar_y_b,gra_still,bar_x_l, bar_x_r, rom_next_enemy, rom_bit_enemy, ball_x_l)
	begin
		hit <='0';
		miss <= '0';
      enemy_vx_next <= enemy_vx_reg;
      enemy_vy_next <= enemy_vy_reg;
		--rom_next_enemy <= rom_bit_enemy;
		if gra_still='1' then            --initial velocity
         enemy_vx_next <= ENEMY_V_Z;
         enemy_vy_next <= ENEMY_V_Z;
			
		elsif (enemy_x_r = bar_x_r and enemy_y_t = bar_y_b) or -- left bottom
				(enemy_x_r = bar_x_r and enemy_y_b = bar_y_t) or -- left top
				(enemy_x_l = bar_x_l and enemy_y_t = bar_y_b) or -- rigth bottom
				(enemy_x_l = bar_x_l and enemy_y_b = bar_y_t) then -- rigth top
				--(enemy_x_r = bar_x_r and enemy_y_b = bar_y_t) or -- rigth top
				--(enemy_x_r = bar_x_l 
			miss <= '1';

--		elsif enemy_x_r = ball_x_l then
--			hit <= '1';
--			enemy_vx_next <= ENEMY_V_Z;
--         enemy_vy_next <= ENEMY_V_Z;
--			
			--rst_enemy <= '1';
			
		elsif enemy_y_t = WALL_Y_B_T then          -- reach top
         enemy_vy_next <= ENEMY_V_P;
      elsif enemy_y_b = WALL_Y_T_B then  -- reach bottom
         enemy_vy_next <= enemy_V_N;
      elsif enemy_x_l = WALL_X_R_L  then -- reach left border
         enemy_vx_next <= enemy_V_P; 
		elsif (enemy_x_r = WALL_X_L_R) then     -- reach right border
			enemy_vx_next <= enemy_V_N; 
			
		elsif enemy_x_r < bar_x_l and enemy_y_t > bar_y_b then--and enemy_y_t < WALL_Y_B_T then --left bottom of player
			enemy_vx_next <= ENEMY_V_P;
			enemy_vy_next <= ENEMY_V_N;
		elsif enemy_x_r < bar_x_l and enemy_y_b < bar_y_t then--and enemy_y_b > WALL_Y_T_B then --left top of player
			enemy_vx_next <= ENEMY_V_P;
			enemy_vy_next <= ENEMY_V_P;
		elsif enemy_x_l > bar_x_r and enemy_y_t > bar_y_b then--and enemy_y_t < WALL_Y_B_T then --right bottom of player
			enemy_vx_next <= ENEMY_V_N;
			enemy_vy_next <= ENEMY_V_N;
		elsif enemy_x_l > bar_x_r and enemy_y_b < bar_y_t then--and enemy_y_b > WALL_Y_T_B then --right top of player
			enemy_vx_next <= ENEMY_V_N;
			enemy_vy_next <= ENEMY_V_P;
			
		elsif enemy_x_r < bar_x_l then	--left of player
			enemy_vx_next <= ENEMY_V_P;
		elsif enemy_x_l > bar_x_r then	--right of player
			enemy_vx_next <= ENEMY_V_N;
		elsif enemy_y_b < bar_y_t then	--top of player
			enemy_vy_next <= ENEMY_V_P;
		elsif enemy_y_t > bar_y_b then	--bottom of player
			enemy_vy_next <= ENEMY_V_N;
			
      elsif (BAR_X_L<=enemy_x_r) and (enemy_x_r<=BAR_X_R) and
            (bar_y_t<=enemy_y_b) and (enemy_y_t<=bar_y_b) then
            -- reach x of right bar, a hit
            enemy_vx_next <= enemy_V_N; -- bounce back
            --hit <= '1';
		
      end if;
   end process;
	-----------------------------------------------------------
	
	
	
   -- rgb multiplexing circuit
   process(wall_on,rd_ball_on,wall_rgb,player_rgb,ball_rgb, enemy_on, enemy_rgb)
   begin
      if wall_on='1' then
         rgb <= wall_rgb;
      elsif player_on='1' then
         rgb <= player_rgb;
		elsif enemy_on ='1' then 
			rgb <= enemy_rgb;
      elsif rd_ball_on='1' then
         rgb <= ball_rgb;
			--rgb <= "101";
      else
         rgb <= "111"; -- yellow background
      end if;
   end process;
   -- new graphic_on signal
   graph_on <= wall_on or player_on or rd_ball_on or enemy_on;
end arch;
