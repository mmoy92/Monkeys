using MyGame;
using PlayerIO.GameLibrary;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mygame
{
    public class ChamberA : Zone
    {
        private int lobbyTime;
        private int testTime;
        private int roomStartTime;
        private int waitTime;


        private int numMid;
        private int numRed;
        private int numBlue;
        private int blueReward;
        private int redReward;

        private const int minPlayers = 2;
        private const int majorityReward = 3;
        private const int minorityReward = 10;

        public float[] leftSideX = new float[] { -47, 412, 310, -47 };
        public float[] leftSideY = new float[] { 230, 230, 495, 495 };
        public float[] rightSideX = new float[] { 978, 1436, 1436, 1080 };
        public float[] rightSideY = new float[] { 230, 230, 495, 495 };
        public ChamberA(GameCode g)
            : base(g)
        {
            tag = 0;

        }

        public override void initVars()
        {
            base.initVars();
            lobbyTime = 4000;
            testTime = 15000;
            roomStartTime = 7500;
            waitTime = 3000;

            numMid = 0;
            numRed = 0;
            numBlue = 0;
            blueReward = 0;
            redReward = 0;

            polyX = new float[] { 0, -182, 1512, 1512, -182, -182, 0, 178, 1212, 1396, 0, 178, 0 };
            polyY = new float[] { 0, 124, 124, 600, 600, 124, 0, 240, 240, 480, 480, 240, 0 };
        }
        public override void playerJoined(Player player)
        {
            base.playerJoined(player);

            if (phase == "Waiting" || phase == "LobbyDelay")
            {
                player.inGame = true;
                player.team = 0;
                if (players.Count >= minPlayers && phase == "Waiting")
                {
                    phase = "LobbyDelay";
                }
            }

            player.x = 190 + rand.Next(600);
            player.y = 260 + rand.Next(200);
            game.Zonecast(this, "UserJoined", player.Id, player.x, player.y, player.bananas, player.inGame, player.Name);
        }
        public override void update(int msDiff)
        {
            base.update(msDiff);
            if (phase == "LobbyDelay")
            {
                lobbyTime -= msDiff;
                if (lobbyTime <= 0)
                {
                    phase = "RoomStart";
                    freezeInput();
                    foreach (Player guy in players)
                    {
                        if (guy.inGame)
                        {
                            if (guy.x < 695 - 200)
                            {
                                guy.x = 695 - 200;
                            } else if  (guy.x > 695 + 200)
                            {
                                guy.x = 695 + 200;
                            }
                        }
                    }
                    game.Zonecast(this, "RoomStart");
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
                            guy.freeMovement = true;

                        }
                    }
                    phase = "Testing";
                    game.Zonecast(this, "TestStart");
                }
            }
            else if (phase == "Testing")
            {
                testTime -= msDiff;
                if (testTime <= 0)
                {
                    foreach (Player guy in players)
                    {
                        if (guy.inGame)
                        {
                            if (hitTest(leftSideX, leftSideY, guy.x, guy.y))
                            {
                                numRed++;
                                guy.team = 1;
                            }
                            else if (hitTest(rightSideX, rightSideY, guy.x, guy.y))
                            {
                                numBlue++;
                                guy.team = 2;
                            }
                            else
                            {
                                numMid++;
                                guy.team = 0;
                            }
                        }
                    }
                    blueReward = numBlue < numRed ? minorityReward : majorityReward;
                    redReward = numRed < numBlue ? minorityReward : majorityReward;
                    if (numBlue == numRed)
                    {
                        blueReward = redReward = 0;
                    }
                    phase = "Results";
                    freezeInput();
                }
            }
            else if (phase == "PostWait")
            {
                waitTime -= msDiff;
                if (waitTime <= 0)
                {
                    phase = "Advance";
                    game.Zonecast(this, "Advance");
                    foreach (Player guy in players)
                    {
                        guy.inGame = false;
                        game.chamberB.playerJoined(guy);
                    }
                    initVars();
                }
            }
        }

        public override void updateState(int msDiff)
        {
            base.updateState(msDiff);
        }
        public override void gotMessage(Player player, Message m)
        {
            switch (m.Type)
            {
                case "RequestReward":
                    int reward = 0;
                    if (player.team == 1)
                    {
                        reward = redReward;
                    }
                    else if (player.team == 2)
                    {
                        reward = blueReward;
                    }
                    game.RewardBananas(this, player, reward);

                    break;
                case "PostWait":
                    foreach (Player guy in players)
                    {
                        guy.freeMovement = true;
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
