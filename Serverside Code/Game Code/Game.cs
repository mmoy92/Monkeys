using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;
using Mygame;

namespace MyGame
{
    public class Player : BasePlayer
    {
        public string Name = "";
        public float x = 0;
        public float y = 0;
        //location last state update
        public float oldX = 0;
        public float oldY = 0;
        // if they are pressing the key 
        public bool keyUp = false;
        public bool keyDown = false;
        public bool keyRight = false;
        public bool keyLeft = false;
        public bool canMoveLeft = true;
        public bool canMoveRight = true;
        public bool canMoveUp = true;
        public bool canMoveDown = true;
        public bool freeMovement = true;
        public bool sitting = false;
        public float FMDelay = 0;
        public float DCDelay = 0;
        public int bananas = 0;
        public bool inGame = false;
        public int team = 0;
        public string weapon = "None";
        public int ping = 0;
        public Zone zone;
    }
    [RoomType("GameRoom")]
    public class GameCode : Game<Player>
    {
        DateTime oldTickTime = new DateTime();
        DateTime oldStateTime = new DateTime();
        TimeSpan diff = new TimeSpan();
        bool doState = false;
        PointF vel = new PointF(0.2f, 0.2f);
        Zone[] allZones;
        public ChamberA chamberA;
        public ChamberB chamberB;
        public ChamberC chamberC;

        // This method is called when an instance of your the game is created
        public override void GameStarted()
        {
            chamberA = new ChamberA(this);
            chamberB = new ChamberB(this);
            chamberC = new ChamberC(this);

            allZones = new Zone[] { chamberA, chamberB, chamberC };

            oldTickTime = DateTime.Now;
            oldStateTime = DateTime.Now;

            // Add game tick every 50 ms
            AddTimer(tick, 50);

            Console.WriteLine("Game is started: " + RoomId);

        }
        // called every 50 ms
        private void tick()
        {
            //Get the time elapsed since the last tick
            DateTime newTime = DateTime.Now;
            //The difference in ms
            int msDiff = (newTime - oldTickTime).Milliseconds;
            //Renew the time of the last update
            oldTickTime = newTime;

            foreach (Zone zone in allZones)
            {
                if (zone.players.Count > 0)
                {
                    zone.update(msDiff);
                }
            }


            //Move each player
            foreach (Player guy in Players)
            {
                if (guy.FMDelay > 0)
                {
                    guy.FMDelay -= msDiff;
                    if (guy.FMDelay <= guy.ping)
                    {
                        guy.freeMovement = true;
                        Zonecast(guy.zone, "UpdateFM", guy.Id, guy.freeMovement);
                    }
                }
                if (guy.DCDelay > 0)
                {
                    guy.DCDelay -= msDiff;
                    if (guy.DCDelay <= guy.ping)
                    {
                        guy.Disconnect();
                    }
                }
                if (guy.freeMovement)
                {
                    //Right bounds
                    if (guy.canMoveRight)
                    {
                        if (guy.zone.levelHitTest(guy.x + 25, guy.y))
                        {
                            guy.canMoveRight = false;
                        }
                    }
                    else if (!guy.zone.levelHitTest(guy.x + 25, guy.y))
                    {
                        guy.canMoveRight = true;
                    }
                    //Left bounds
                    if (guy.canMoveLeft)
                    {
                        if (guy.zone.levelHitTest(guy.x - 25, guy.y))
                        {
                            guy.canMoveLeft = false;
                        }
                    }
                    else if (!guy.zone.levelHitTest(guy.x - 25, guy.y))
                    {
                        guy.canMoveLeft = true;
                    }
                    //Top bounds
                    if (guy.canMoveUp)
                    {
                        if (guy.zone.levelHitTest(guy.x, guy.y - 15))
                        {
                            guy.canMoveUp = false;
                        }
                    }
                    else if (!guy.zone.levelHitTest(guy.x, guy.y - 15))
                    {
                        guy.canMoveUp = true;
                    }
                    //Bottom bounds
                    if (guy.canMoveDown)
                    {
                        if (guy.zone.levelHitTest(guy.x, guy.y + 15))
                        {
                            guy.canMoveDown = false;
                        }
                    }
                    else if (!guy.zone.levelHitTest(guy.x, guy.y + 15))
                    {
                        guy.canMoveDown = true;
                    }

                    if (guy.canMoveUp && guy.keyUp)
                    {
                        guy.y -= (int)(msDiff * vel.Y);
                    }
                    if (guy.canMoveDown && guy.keyDown)
                    {
                        guy.y += (int)(msDiff * vel.Y);
                    }
                    if (guy.canMoveRight && guy.keyRight)
                    {
                        guy.x += (int)(msDiff * vel.X);
                    }
                    if (guy.canMoveLeft && guy.keyLeft)
                    {
                        guy.x -= (int)(msDiff * vel.X);
                    }
                }
            }

            // Sends the state update every other tick
            if (doState)
            {
                //Compute the time since the last update was sent
                diff = newTime - oldStateTime;
                msDiff = diff.Milliseconds;

                foreach (Zone zone in allZones)
                {
                    if (zone.players.Count > 0)
                    {
                        zone.updateState(msDiff);
                    }
                }

                doState = false;
                oldStateTime = newTime;


            }
            else
            {
                doState = true;
            }
        }
        // This method is called when the last player leaves the room, and it's closed down.
        public override void GameClosed()
        {
            Console.WriteLine("RoomId: " + RoomId);
        }

        // This method is called whenever a player joins the game
        public override void UserJoined(Player player)
        {
            //Determine zone to place player in
            player.zone = chamberA;


            player.zone.playerJoined(player);

            PlayerIO.BigDB.Load("World", "Stats", delegate(DatabaseObject result)
            {
                if (result != null)
                {
                    int curNumCreated = result.GetInt("NumCreated", 0);
                    curNumCreated++;
                    //Change a property and save back.
                    result.Set("NumCreated", curNumCreated);
                    result.Save(null);
                }
            });

        }

        // This method is called when a player leaves the game
        public override void UserLeft(Player player)
        {
            player.zone.playerLeft(player);
        }
        // This method is called when a player sends a message into the server code
        public override void GotMessage(Player player, Message m)
        {
            //Get the current time
            DateTime newTime = DateTime.Now;
            diff = newTime - oldStateTime;
            //Get the difference from last state update in ms
            int msDiff = diff.Milliseconds;
            Zone z = player.zone;
            //Record and re-route keypresses
            switch (m.Type)
            {
                case "uUp":
                    Zonecast(z, "uUp", player.Id);
                    player.keyUp = false;
                    break;
                case "uDown":
                    Zonecast(z, "uDown", player.Id);
                    player.keyUp = true;
                    break;
                case "dUp":
                    Zonecast(z, "dUp", player.Id);
                    player.keyDown = false;
                    break;
                case "dDown":
                    Zonecast(z, "dDown", player.Id);
                    player.keyDown = true;
                    break;
                case "rUp":
                    Zonecast(z, "rUp", player.Id);
                    player.keyRight = false;
                    break;
                case "rDown":
                    Zonecast(z, "rDown", player.Id);
                    player.keyRight = true;
                    break;
                case "lUp":
                    Zonecast(z, "lUp", player.Id);
                    player.keyLeft = false;
                    break;
                case "lDown":
                    Zonecast(z, "lDown", player.Id);
                    player.keyLeft = true;
                    break;
                case "KeysFalse":
                    player.keyLeft = false;
                    player.keyRight = false;
                    player.keyUp = false;
                    player.keyDown = false;
                    Zonecast(z, "KeysFalse", player.Id);
                    break;
                case "FM":
                    player.freeMovement = m.GetBoolean(0);
                    Zonecast(z, "UpdateFM", player.Id, player.freeMovement);
                    break;
                case "Rewind":
                    player.Send("Correction", player.x, player.y, player.canMoveDown, player.canMoveUp, player.canMoveRight, player.canMoveLeft);
                    break;
                case "Ping":
                    player.Send("Pong", m.GetDouble(0));
                    break;
                case "PingUpdate":
                    player.ping = m.GetInt(0);
                    break;
                case "NameUpdate":
                    player.Name = m.GetString(0);
                    Zonecast(z, "NameUpdate", player.Id, player.Name);
                    break;
                case "Stab":

                    z.freezeInput(player);
                    player.FMDelay = 700;
                    Zonecast(z, "DoStab", player.Id);
                    foreach (Player other in z.players)
                    {
                        if (other.Id == m.GetInteger(0))
                        {
                            Console.WriteLine("found victim");
                            if (player.weapon == "dagger" && z.inRange((int)player.x, (int)player.y, (int)other.x, (int)other.y, 75, 40) && other != player)
                            {
                                Console.WriteLine("Successful stab");
                                z.freezeInput(other);
                                other.DCDelay = 2000;
                                player.Send("UpdateStab", other.Id, true);
                                ZonecastOmit(z, player, "StabAction", player.Id, other.Id);
                            }
                            else
                            {
                                player.Send("UpdateStab", other.Id, false);
                                Console.WriteLine("Failed stab");
                                ZonecastOmit(z, player, "StabAction", player.Id, -1);
                            }
                            break;
                        }
                    }
                    break;
                case "chat":
                    Zonecast(z, "chat", player.Id, player.ConnectUserId + ": " + m.GetString(0));
                    break;
                default:
                    z.gotMessage(player, m);
                    break;
            }
        }
        public void RewardBananas(Zone z, Player player, int amt)
        {
            player.bananas += amt;
            Zonecast(z, "RewardBanana", player.Id, player.bananas);
        }
        public void Zonecast(Zone z, Message message)
        {
            foreach (Player guy in Players)
            {
                if (guy.zone == z)
                {
                    guy.Send(message);
                }
            }

        }
        public void Zonecast(Zone z, string type, params object[] parameters)
        {
           
            foreach (Player guy in Players)
            {
                if (guy.zone == z)
                {
                    guy.Send(type, parameters);
                }
            }

        }
        //Zonecast Omit a player
        public void ZonecastOmit(Zone z, Player p, Message message)
        {
            foreach (Player guy in Players)
            {
                if (guy.zone == z && guy != p)
                {
                    guy.Send(message);
                }
            }

        }
        public void ZonecastOmit(Zone z, Player p, string type, params object[] parameters)
        {

            foreach (Player guy in Players)
            {
                if (guy.zone == z && guy != p)
                {
                    guy.Send(type, parameters);
                }
            }

        }




        Point debugPoint;

        // During development, it's very usefull to be able to cause certain events
        // to occur in your serverside code. If you create a public method with no
        // arguments and add a [DebugAction] attribute like we've down below, a button
        // will be added to the development server. 
        // Whenever you click the button, your code will run.
        [DebugAction("Play", DebugAction.Icon.Play)]
        public void PlayNow()
        {
            Console.WriteLine(chamberB.phase + chamberB.players + "");
        }

        // If you use the [DebugAction] attribute on a method with
        // two int arguments, the action will be triggered via the
        // debug view when you click the debug view on a running game.
        [DebugAction("Set Debug Point", DebugAction.Icon.Green)]
        public void SetDebugPoint(int x, int y)
        {
            debugPoint = new Point(x, y);
        }
    }
}
