package enemies {
	import flash.geom.Point;
	import gameobj.RoundBullet;
	import org.flixel.FlxBasic;
	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import particle.LaserSight;
	import particle.SpeechParticle;
	
	public class SniperEnemy extends BaseEnemy {
		
		// cluster of battling judgements
		private var _tactical_step:Number;
		public var _hide_timer:int;
		public var _hide_timer_limit:int;
		public var _vulnerable_timer:int;
		public var _vulnerable_limit:int;
		public var _shoot_timer:int;
		public var _shoot_delay:int;
		
		private var _laser_sight:LaserSight;
		
		public var _group:FlxGroup;
		public var _target:Point = new Point();
		
		// relative position of gun's muzzle
		public var _gun_x:Number;
		public var _gun_y:Number;
		
		public function SniperEnemy(team_no:Number, g:GameEngine) {
			// auto: hp=10, shoot=false, angle=0, hiding=false
			super(team_no);
			this._angle = (_team_no == 1) ? 0:( -180);
			this._hp = 50;
			
			this._hiding = true;
			this._tactical_step = 1;
			this._hide_timer = 0;
			this._hide_timer_limit = Util.int_random(60, 600);
			this._shoot_timer = 0;
			this._shoot_delay = Util.int_random(45, 60);
			this._vulnerable_timer = 0;
			this._vulnerable_limit = 60;
			this._group = null;
			
			// initialize laser sight
			this._laser_sight = new LaserSight();
			_laser_sight.loadGraphic(Resource.IMPORT_LASER_SIGHT);
			_laser_sight.visible = false;
			_laser_sight.angle = _angle;
			g._particles.add(_laser_sight);
			
			if (this._team_no == 1) {
				this.loadGraphic(Resource.IMPORT_ENEMY_RED);
			} else {	// _team_no == 2
				this.loadGraphic(Resource.IMPORT_ENEMY_BLUE);
			}
			this.visible = false;
		}
		
		override public function enemy_update(game:GameEngine):void {
			if (!this.alive) {
				_laser_sight.visible = false;
			} else {
				var team_sign = (_team_no == 1) ? 1:( -1);
				var dx:Number = (_team_no == 1) ? 62 : 0;
				var dy:Number = 25.71 * Math.sin(Math.atan(6 / 25) - this.angle * Util.RADIAN * team_sign);
				_laser_sight.y = this.y + 14 - dy;
				_laser_sight.set_position(this.x + dx - 320, _laser_sight.y);
				if (!_hiding) {
					switch(_tactical_step) {
						case 1:
							// show up, be vulnerable, proceed
							_laser_sight.visible = true;
							this.visible = true;
							if (_vulnerable_timer >= _vulnerable_limit) {
								// vulnerability delay
								_vulnerable_timer = 0;
								_tactical_step = 2;
							} else {
								_vulnerable_timer++;
							}
							break;
						case 2:
							// finding target; if successfully, go on, otherwise retreat
							this.visible = true;
							search_new_target(game._enemies);
							_tactical_step = 3;
							break;
						case 3:
							// aim
							this.visible = true;
							_laser_sight.angle = _angle;
							var goal_angle:Number = Math.atan2(_target.y - this.y, _target.x - this.x) * Util.DEGREE;
							var err:Number = _angle-goal_angle;
							var err_tol:Number = Util.float_random(0.5, 1.5);
							
							if (Math.abs(err) <= err_tol) {
								// aim successfully
								_tactical_step = 4;
							} else {
								if (err >= 270) {
									_angle = _angle - 360;
								} else if (err <= -270 ) {
									_angle = _angle + 360;
								}
								var dtheta:Number = (goal_angle - _angle) / 10;
								_angle += dtheta;
								if (this._team_no == 1) {
									this.angle = _angle;
								} else {
									// _team_no == 2
									this.angle = _angle + 180;
								}
								var dy:Number = 25.71 * Math.sin(Math.atan(6 / 25) - this.angle * Util.RADIAN * team_sign);
								_laser_sight.y = this.y + 14 - dy;
							}
							break;
						case 4:
							this.visible = true;
							_shoot_timer++;
							if (_shoot_timer >= _shoot_delay) {
								_shoot_timer = 0;
								
								_laser_sight.visible = false;
								var choice:Number = 1;
								// shoot
								var dx:Number = (this._team_no == 1) ? 62 : -6;
								var bullet:RoundBullet = new RoundBullet(this.x + dx, _laser_sight.y - 5, this._angle);
								game._bullets.add(bullet);
								FlxG.play(Resource.IMPORT_SOUND_SNIPER_SHOOT, 0.8);
								_tactical_step = 5;
								
							} else {
								// in shoot delay
								_laser_sight.visible = true;
							}
							break;
						case 5:
							if (_vulnerable_timer >= _vulnerable_limit) {
								// post-shoot delay
								retreat(game._enemies);
								
							} else {
								_vulnerable_timer++;
							}
							break;
						default:
							_tactical_step = 1;
							break;
					}
				} else {	// hide for some time
					this.visible = false;
					if (_hide_timer >= _hide_timer_limit) {
						add_speech_bubble(game);
						_hiding = false;
						reset_hide_timer();
					} else {
						_hide_timer++;
					}
				}
			}
		}
		
		private function add_speech_bubble(g:GameEngine):void {
			if (Util.int_random(0, 10) != 0) return;
			var text:String = "top kek";
			var offsetx:Number = 0;
			var offsety:Number = 0;
			var seed:Number = Util.int_random(0, 4);
			if (_team_no == 1) {
				offsetx = 10;
				offsety = -15;
				if (seed == 0) {
					text = "I love you mommy!";
				} else if (seed == 1) {
					text = "Do you even lift bro?";
				} else if (seed == 2) {
					text = "For the motherland!";
				} else {
					text = "Die, Montague scum!";
				}
				
			} else if (_team_no == 2) {
				offsetx = 20;
				offsety = -15;
				if (seed == 0) {
					text = "This is so kawaii!";
				} else if (seed == 1) {
					text = "If it's red it's dead!";
				} else if (seed == 2) {
					text = "Cover me!";
				} else {
					text = "Die, Capulet scum!";
				}
			}
			
			g.add_particle(new SpeechParticle(this, text, g, offsetx, offsety));
		}
		
		public function retreat(enemies_group:FlxGroup):void {
			_hiding = true;
			_tactical_step = 1;
			_vulnerable_timer = 0;
			_vulnerable_limit = Util.int_random(60, 180);
			_shoot_timer = 0;
			_laser_sight.visible = false;
			this.visible = false;
			move_to_a_location(enemies_group);
		}
		
		private var _positions:Vector.<Point> = new Vector.<Point>();
		public function add_position(x:Number, y:Number):void {
			if (_positions.length == 0) set_position(x, y);
			_positions.push(new Point(x, y));
		}
		public function move_to_a_location(enemy_group:FlxGroup):void {
			if (_positions.length == 0) return;
			for each(var p:Point in _positions) {
				var too_close:Boolean = false;
				for each(var e:BaseEnemy in enemy_group.members) {
					if (e != this && Util.point_dist(p.x, p.y, e.x, e.y) < 10) {
						too_close = true;
						break;
					}
				}
				if (!too_close) {
					set_position(p.x, p.y);
					_positions.push(_positions.shift());
					return;
				}
			}
		}
		
		// returns a boolean that indicates whether a target is found
		public function search_new_target(enemies:FlxGroup):Boolean {
			_group = enemies;
			if (_group != null) {
				// randomly target someone from the group; if it's an enemy, then target succeed
				var trial:Number = 1;
				var max_trial:Number = Util.int_random(10, 15);
				while (trial <= max_trial) {
					var possible_target:BaseEnemy = _group.getRandom() as BaseEnemy;
					if (possible_target._team_no != this._team_no /*&& possible_target.visible && possible_target.alive*/) {
						_target.x = possible_target.x;
						_target.y = possible_target.y;
						return true;
					}
					trial++;
				}
			}
			return false;
		}
		
		public function is_hiding():Boolean {
			return _hiding;
		}
		
		public function reset_hide_timer():void {
			_hide_timer = 0;
			_hide_timer_limit = Util.int_random(60, 300);
		}
	}
}