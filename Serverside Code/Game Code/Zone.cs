using PlayerIO.GameLibrary;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyGame
{
    public class Zone
    {
        protected GameCode game;
        public List<Player> players;

        public Random rand;
        public float[] polyX;
        public float[] polyY;
        public String phase;
        public int tag;
        public Zone() { }
        public Zone(GameCode g)
        {
            game = g;
            
            initVars();
        }
        public virtual void initVars()
        {
            players = new List<Player>();
            rand = new Random();
            phase = "Waiting";
        }
        public virtual void playerJoined(Player player)
        {
            players.Add(player);
            player.zone = this;

            //Make a message to bring the new player up to speed
            Message upToSpeed = Message.Create("GetWorldState");
            upToSpeed.Add(phase);
            upToSpeed.Add(player.Id);

            //Add all the player's data
            foreach (Player guy in players)
            {
                if (guy != player)
                {
                    upToSpeed.Add(guy.Id, guy.x, guy.y, guy.keyUp, guy.keyDown, guy.keyRight, guy.keyLeft, guy.bananas, guy.inGame, guy.Name);
                }
            }
            player.Send(upToSpeed);
        }
        public virtual void playerLeft(Player player)
        {
            players.Remove(player);
            game.Zonecast(this,"UserLeft", player.Id);
        }
        public virtual void update(int msDiff)
        {
           
        }
        public virtual void updateState(int msDiff)
        {
            //Compose the state message
            Message stateUpdate = Message.Create("State");
            stateUpdate.Add(msDiff);
            //Put all users into the same message
            foreach (Player guy in players.ToList())
            {
                //Only send an update if the user has changed position
                if (guy.oldX != guy.x || guy.oldY != guy.y)
                {
                    stateUpdate.Add(guy.Id, guy.x, guy.y);
                    guy.oldX = guy.x;
                    guy.oldY = guy.y;
                }
            }

            game.Zonecast(this,stateUpdate);
        }
        public virtual void gotMessage(Player player, Message m)
        {
           
        }
        public Boolean inRange(int ax, int ay, int bx, int by, int halfRangeX, int halfRangeY)
        {
            return (ax >= bx - halfRangeX && ax <= bx + halfRangeX && ay >= by - halfRangeY && ay <= by + halfRangeY);
        }
        public Boolean levelHitTest(float testx, float testy)
        {

            return hitTest(polyX, polyY, testx, testy);
        }
        public Boolean hitTest(float[] listX, float[] listY, float testx, float testy)
        {

            int i, j = 0;
            Boolean c = false;
            for (i = 0, j = listX.Length - 1; i < listX.Length; j = i++)
            {
                if (((listY[i] > testy) != (listY[j] > testy)) &&
                 (testx < (listX[j] - listX[i]) * (testy - listY[i]) / (listY[j] - listY[i]) + listX[i]))
                    c = !c;
            }
            return c;
        }
        public void freezeInput(Player guy)
        {
            guy.freeMovement = false;
        }
        public void freezeInput()
        {
            foreach (Player guy in players)
            {
                if (guy.inGame)
                {
                    guy.freeMovement = false;
                }
            }
        }
        public void freeInput()
        {
            foreach (Player guy in players)
            {
                if (guy.inGame)
                {
                    guy.freeMovement = true;
                }
            }
        }
    }
}
