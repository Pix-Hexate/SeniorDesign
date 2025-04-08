extends Node
#This will handle all signals passed around, every class that needs to send or recieve signals will connect to this

# For example, enemies dying might trigger OnEnemyDeath signal, which will cause this node to emit the signal
# Then, the GameManager that's connected to the signal will read that and increment a counter for statistics
# And also, an Item that the character owns that heals the charater when an enemy dies might also read it, and heal the character


signal EnemyDied(Enemy : EnemyBaseScene)

signal EnemyHit(Enemy : EnemyBaseScene)

signal WIN()
