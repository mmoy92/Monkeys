using MyGame;
using PlayerIO.GameLibrary;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mygame
{
    public class Balloon
    {
        public int x;
        public int y;
        public int reward;
        public int tag;
        public int fallTime = 2800;
        public Balloon(int _x, int _y, int _reward, int _tag)
        {
            x = _x;
            y = _y;
            tag = _tag;
            reward = _reward;
        }

    }
    public class Chair
    {
        public int x;
        public int y;
        public int tag;
        public Player occupant;
        public Chair(int _x, int _y, int _tag)
        {
            x = _x;
            y = _y;
            tag = _tag;
        }

    }
    public class ChamberB : Zone
    {
        private int lobbyTime;
        private int roomStartTime;
        private int richTime;
        private int waitTime;
        private int balloonTime;
        private int balloonLimit;
        private const int minPlayers = 2;
        private int numPlayers;
        private int numSitting;
        private bool isRich;
        private List<Balloon> balloons;
        private List<Chair> chairs;
        private List<Player> eliminated;
        private int bloonTags;
        private int chairTags;
        public ChamberB(GameCode g)
            : base(g)
        {
            tag = 1;

        }
        public override void initVars()
        {
            base.initVars();
            lobbyTime = 4000;
            roomStartTime = 7000;
            richTime = 8000;
            waitTime = 3000;
            balloonTime = 1000;
            balloonLimit = 25;

            numSitting = 0;
            numPlayers = 0;
            isRich = false;
            balloons = new List<Balloon>();
            chairs = new List<Chair>();
            eliminated = new List<Player>();
            bloonTags = 0;
            chairTags = 0;

            polyX = new float[] { 0, -179, 2437, 2437, -179, -179, 0, 183, 492, 366, 0, 183, 0, 596, 2137, 2322, 470, 596, 0 };
            polyY = new float[] { 0, 122, 122, 600, 600, 122, 0, 240, 240, 479, 479, 240, 0, 240, 240, 479, 479, 240, 0 };
        }
        public override void playerJoined(Player player)
        {
            base.playerJoined(player);

            if (phase == "Waiting" || phase == "LobbyDelay")
            {
                player.inGame = true;
                numPlayers++;
                if (phase == "Waiting" && numPlayers >= minPlayers)
                {
                    phase = "LobbyDelay";
                }
            }
            player.y = 260 + rand.Next(200);
            if (player.bananas < 10)
            {
                player.x = 190 + rand.Next(150);
            }
            else
            {
                player.x = 600 + rand.Next(150);
                isRich = true;
            }
            game.Zonecast(this, "UserJoined", player.Id, player.x, player.y, player.bananas, player.inGame, player.Name, player.bananas);
        }
        public override void playerLeft(Player player)
        {
            //Remove the chair the player is sitting in, preferably
            if (player.inGame)
            {
                numPlayers--;
                if (player.sitting)
                {
                    foreach (Chair chair in chairs)
                    {
                        if (chair.occupant == player)
                        {
                            numSitting--;
                            chairs.Remove(chair);
                            break;
                        }
                    }
                }
                else
                {
                    foreach (Chair chair in chairs)
                    {
                        if (chair.occupant == null)
                        {
                            game.Zonecast(this, "RemoveChair", chair.tag);
                            chairs.Remove(chair);
                            break;
                        }
                    }
                }
            }
            base.playerLeft(player);
        }
        public override void update(int msDiff)
        {
            base.update(msDiff);
            if (phase == "LobbyDelay")
            {
                lobbyTime -= msDiff;
                if (lobbyTime <= 0)
                {
                    Message chairMsg = Message.Create("RoomStart");
                    for (int i = 0; i < numPlayers - 1; i++)
                    {
                        int cx = 2130 - rand.Next(250);
                        int cy = 250 + rand.Next(210);

                        chairTags++;
                        Chair newChair = new Chair(cx, cy, chairTags);
                        chairs.Add(newChair);

                        chairMsg.Add(cx, cy, newChair.tag);

                    }
                    phase = "RoomStart";
                    game.Zonecast(this, chairMsg);
                }
            }
            else if (phase == "RoomStart")
            {
                roomStartTime -= msDiff;
                if (roomStartTime <= 0)
                {
                    foreach (Player guy in players)
                    {
                        if (guy.inGame)
                        {
                            if (guy.bananas >= 10)
                            {
                                guy.freeMovement = true;
                            }
                        }
                    }
                    phase = "RichTesting";
                    game.Zonecast(this, "RichStart");
                }
            }
            else if (phase == "RichTesting")
            {
                richTime -= msDiff;
                if (richTime <= 0 || !isRich)
                {
                    polyX = new float[] { 0, -179, 2437, 2437, -179, -179, 0, 183, 2137, 2322, 0, 183, 0 };
                    polyY = new float[] { 0, 122, 122, 600, 600, 122, 0, 240, 240, 479, 479, 240, 0 };

                    freeInput();
                    phase = "Testing";
                    game.Zonecast(this, "TestStart");
                }
                updateBalloons(msDiff);
            }
            else if (phase == "Testing")
            {
                updateBalloons(msDiff);
                if (numSitting >= numPlayers - 1)
                {
                    freezeInput();
                    Message resultsMsg = Message.Create("Results");
                    foreach (Player guy in players)
                    {
                        if (guy.inGame)
                        {
                            if (!guy.sitting)
                            {
                                resultsMsg.Add(guy.Id);
                                if (guy.x < 650)
                                {
                                    guy.x = 650;
                                }
                                else if (guy.x > 1150)
                                {
                                    guy.x = 1150;
                                }
                                eliminated.Add(guy);
                                break;
                            }
                        }
                    }
                    phase = "Results";
                    game.Zonecast(this, resultsMsg);
                }
            }
            else if (phase == "PostWait")
            {
                waitTime -= msDiff;
                if (waitTime <= 0)
                {
                    phase = "Advance";
                    game.Zonecast(this, "AdvanceB");
                    foreach (Player guy in players)
                    {
                        guy.inGame = false;
                        game.chamberC.playerJoined(guy);
                    }
                    initVars();

                }
            }
        }
        private void updateBalloons(int msDiff)
        {
            balloonTime -= msDiff;
            if (balloonTime <= 0 && balloonLimit > 0)
            {
                balloonLimit--;

                balloonTime = 1000 + rand.Next(1700);
                int bx = 600 + rand.Next(650);
                int by = 250 + rand.Next(210);
                bloonTags++;
                balloons.Add(new Balloon(bx, by, 1 + rand.Next(5), bloonTags));


                game.Zonecast(this, "SpawnBalloon", bx, by, bloonTags);
            }
            foreach (Balloon bloon in balloons)
            {
                if (bloon.fallTime > 0)
                {
                    bloon.fallTime -= msDiff;
                    if (bloon.fallTime <= 0)
                    {
                        game.Zonecast(this, "BalloonReady", bloon.tag);
                    }
                }
            }
        }
        public override void updateState(int msDiff)
        {
            base.updateState(msDiff);
        }
        public override void gotMessage(Player player, Message m)
        {
            int tag;
            switch (m.Type)
            {
                case "TryPop":
                    tag = m.GetInteger(0);
                    player.freeMovement = false;
                    player.FMDelay = 700;
                    foreach (Balloon bloon in balloons)
                    {
                        if (bloon.tag == tag)
                        {
                            if (inRange((int)player.x, (int)player.y, bloon.x, bloon.y, 75, 40))
                            {
                                game.RewardBananas(this, player, bloon.reward);
                                player.Send("UpdatePop", tag, true);
                                game.ZonecastOmit(this, player, "PopAction",player.Id, tag);
                                balloons.Remove(bloon);
                            }
                            else
                            {
                                player.Send("UpdatePop", false);
                            }
                            break;
                        }
                    }
                    
                    break;
                case "ConfirmSit":
                    tag = m.GetInteger(0);
                    foreach (Chair chair in chairs)
                    {
                        if (tag == chair.tag)
                        {
                            if (inRange((int)player.x, (int)player.y, chair.x, chair.y, 75, 40) && chair.occupant == null)
                            {
                                chair.occupant = player;
                                player.x = chair.x;
                                player.y = chair.y + 1;
                                player.sitting = true;
                                freezeInput(player);
                                game.Zonecast(this, "MonkeySat", player.Id, chair.tag);
                                numSitting++;
                            }

                            break;
                        }
                    }

                    break;
                case "PostWait":
                    foreach (Player nub in eliminated)
                    {
                        nub.Disconnect();
                        players.Remove(nub);
                    }
                    foreach (Player guy in players)
                    {
                        guy.freeMovement = true;
                        guy.sitting = false;
                        if (!guy.inGame)
                        {
                            guy.inGame = true;
                        }
                    }

                    phase = "PostWait";
                    break;
            }
        }

    }
}
