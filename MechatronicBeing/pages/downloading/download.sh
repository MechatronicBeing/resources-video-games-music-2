echo "Download (and extract) all remote resources-video-games-music-2 to your local"
curl -LO https://github.com/MechatronicBeing/resources-video-games-music-2/archive/master.tar.gz
tar -xf master.tar.gz
mv resources-video-games-music-2-main resources-video-games-music-2
rm master.tar.gz
