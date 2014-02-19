using MyGame;
using PlayerIO.GameLibrary;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mygame
{
    public class Dagger
    {
        public int x;
        public int y;
        public int tag;
        public int fallTime = 1000;
        public Dagger(int _x, int _y, int _tag)
        {
            x = _x;
            y = _y;
            tag = _tag;
        }

    }
    public class ChamberC : Zone
    {
        private int lobbyTime;
        private int testTime;
        private int roomStartTime;
        private int resultsTime;
        private int autoTime;
        private int waitTime;
       
        private int numPlayers;
        private const int minPlayers = 2;
        private List<Player> reds;
        private List<Player> blues;
        private List<Player> eliminated;
        private int redSum;
        private int blueSum;
        private int winner;
        private Dagger dagger;
        public ChamberC(GameCode g)
            : base(g)
        {
            tag = 2;

        }
        public override void initVars()
        {
            base.initVars();
            lobbyTime = 4000;
            testTime = 15000;
            roomStartTime = 8000;
            resultsTime = 4000;
            autoTime = 4000;
            waitTime = 3000;

            numPlayers = 0;

            reds = new List<Player>();
            blues = new List<Player>();
            eliminated = new List<Player>();

            redSum = 0;
            blueSum = 0;
            winner = 0;

            polyX = new float[] { 0, 1833, 1833, -180, -180, 1833, 0, 1, 762, 763, 695, 695, 592, 590, 132, 1, 0, 900, 1661, 1535, 1068, 1069, 967, 968, 900, 900, 0 };
            polyY = new float[] { 0, 602, 126, 126, 602, 602, 0, 476, 478, 245, 244, 270, 270, 245, 244, 476, 0, 479, 478, 245, 244, 270, 271, 244, 244, 479, 0 };
        }
        public override void playerJoined(Player player)
        {
            base.playerJoined(player);

            if (phase == "Waiting" || phase == "LobbyDelay")
            {
                player.inGame = true;
                player.weapon = "";
                numPlayers++;
                if (reds.Count <= blues.Count)
                {
                    player.team = 1;
                    reds.Add(player);
                    player.x = 130 + rand.Next(50);
                    player.y = 240 + rand.Next(200);
                }
                else
                {
                    player.team = 2;
                    blues.Add(player);
                    player.x = 1530 - rand.Next(50);
                    player.y = 240 + rand.Next(200);
                }
                if (phase == "Waiting" && numPlayers >= minPlayers)
                {
                    phase = "LobbyDelay";
                }
            }
            else
            {
                player.x = 130 + rand.Next(400);
                player.y = 240 + rand.Next(200);
            }
            game.Zonecast(this, "UserJoined", player.Id, player.x, player.y, player.bananas, player.inGame, player.Name, player.bananas);
        }
        public override void playerLeft(Player player)
        {
            base.playerLeft(player);
            numPlayers--;
            if (player.team == 1)
            {
                reds.Remove(player);
            }
            else if (player.team == 2)
            {
                blues.Remove(player);
            }
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
                    game.Zonecast(this, "RoomStart");
                }
            }
            else if (phase == "RoomStart")
            {
                roomStartTime -= msDiff;
                if (roomStartTime <= 0)
                {
                    phase = "Testing";
                    game.Zonecast(this, "TestStart");
                }
            }
            else if (phase == "Testing")
            {
                testTime -= msDiff;
                if (testTime <= 0)
                {
                    phase = "Results";
                    freezeInput();
                    winner = redSum == blueSum ? 0 : (redSum > blueSum ? 1 : 2);
                    game.Zonecast(this, "Results", redSum, blueSum);
                }
            }
            else if (phase == "Results")
            {
                resultsTime -= msDiff;
                if (resultsTime <= 0)
                {
                    Message outcome = Message.Create("JudgeResults");
                    if (winner == 0)
                    {
                        outcome.Add(0);
                        foreach (Player guy in players)
                        {
                            eliminated.Add(guy);
                        }
                        phase = "Autolimination";
                        
                    }else if ((winner == 1 && blues.Count >= 2) || (winner == 2 && reds.Count >= 2))
                    {
                        outcome.Add(1);
                        phase = "Elimination";
                        freeInput();
                        int knifeX = rand.Next(600);
                        int knifeY = 294 + rand.Next(155);

                        knifeX += winner == 1 ? 892 : 137;

                        outcome.Add(knifeX,knifeY,0);
                        dagger = new Dagger(knifeX, knifeY, 0);
                    }
                    else
                    {
                        outcome.Add(2);
                        //There are only 2 players, so eliminate the loser automatically
                        phase = "Autolimination";
                        Player nub = winner == 1? blues[0]:reds[0];

                        eliminated.Add(nub);
                        outcome.Add(nub.Id);
                    }
                    game.Zonecast(this, outcome);
                }
            }
            else if (phase == "Autolimination")
            {
                //Players are automatically being eliminated..please wait
                autoTime -= msDiff;
                if (autoTime <= 0)
                {
                    advanceToPostWait();
                }
            }
            else if (phase == "Elimination")
            {
                updateDagger(msDiff);
                if ((winner == 1 && blues.Count <= 1) || (winner == 2 && reds.Count <= 1))
                {
                    advanceToPostWait();
                }
            }
            else if (phase == "PostWait")
            {
                waitTime -= msDiff;
                if (waitTime <= 0)
                {
                    phase = "Advance";
                    game.Zonecast(this, "AdvanceC");
                    foreach (Player guy in players)
                    {
                        guy.inGame = false;
                        game.chamberA.playerJoined(guy);
                    }
                    initVars();

                }
            }
        }
        private void advanceToPostWait()
        {
            foreach (Player nub in eliminated)
            {
                nub.Disconnect();
                players.Remove(nub);
            }
            foreach (Player guy in players)
            {
                guy.freeMovement = true;
                if (!guy.inGame)
                {
                    guy.inGame = true;
                }
            }


            phase = "PostWait";
            game.Zonecast(this, "PostWait");
        }
        private void updateDagger(int msDiff)
        {
            if (dagger != null)
            {
                if (dagger.fallTime > 0)
                {
                    dagger.fallTime -= msDiff;

                    if (dagger.fallTime <= 0)
                    {
                        Console.WriteLine("DaggerReady send");
                        game.Zonecast(this, "DaggerReady");
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
            switch (m.Type)
            {

                case "Donate":
                    int amt = m.GetInt(0);
                    if (player.bananas >= amt)
                    {
                        player.bananas -= amt;
                        if (player.team == 1)
                        {
                            redSum += amt;
                        }
                        else
                        {
                            blueSum += amt;
                        }
                        player.Send("DeductBanana", player.Id, player.bananas);
                        game.Zonecast(this, "TweenCount", player.team);
                    }

                    break;

                case "ConfirmDagger":
                    if (dagger != null)
                    {
                        if (inRange((int)player.x, (int)player.y, dagger.x, dagger.y, 75, 40))
                        {
                            player.weapon = "dagger";
                            game.Zonecast(this, "DaggerTaken", player.Id);
                            dagger = null;
                        }
                        else
                        {
                            player.Send("DaggerFail");
                        }
                    }
                    break;
            }
        }

    }
}
