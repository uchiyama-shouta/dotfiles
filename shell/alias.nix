{
  dc = "docker-compose";
  dcup = "docker-compose up -d";
  dcup-dev = "docker-compose -f docker-compose.dev.yml up -d";
  dcdown = "docker-compose down --rmi all --volumes --remove-orphans";
  dcex = "(){docker-compose exec $1 ash -c $2}";
}
