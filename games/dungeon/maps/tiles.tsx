<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.10.2" name="tiles" tilewidth="16" tileheight="16" tilecount="1024" columns="32">
 <image source="../assets/textures/tiles.png" width="512" height="512"/>
 <tile id="193">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="194">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="195">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="224">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="225">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="226">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="227">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="256">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="257">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="258">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="259">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="288">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="289">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="290">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="291">
  <properties>
   <property name="type" value="wall"/>
  </properties>
 </tile>
 <tile id="353">
  <properties>
   <property name="open_tile" type="int" value="354"/>
   <property name="state" value="closed"/>
   <property name="type" value="door"/>
  </properties>
 </tile>
 <tile id="354">
  <properties>
   <property name="closed_tile" type="int" value="353"/>
   <property name="state" value="open"/>
   <property name="type" value="door"/>
  </properties>
 </tile>
 <tile id="385">
  <properties>
   <property name="open_tile" type="int" value="386"/>
   <property name="state" value="closed"/>
   <property name="type" value="door"/>
  </properties>
 </tile>
 <tile id="386">
  <properties>
   <property name="closed_tile" type="int" value="385"/>
   <property name="state" value="open"/>
   <property name="type" value="door"/>
  </properties>
 </tile>
 <wangsets>
  <wangset name="walls" type="edge" tile="-1">
   <wangcolor name="red wall" color="#ff0000" tile="-1" probability="1"/>
   <wangtile tileid="193" wangid="0,0,1,0,0,0,0,0"/>
   <wangtile tileid="194" wangid="0,0,1,0,0,0,1,0"/>
   <wangtile tileid="195" wangid="0,0,0,0,0,0,1,0"/>
   <wangtile tileid="224" wangid="0,0,0,0,1,0,0,0"/>
   <wangtile tileid="225" wangid="0,0,1,0,1,0,0,0"/>
   <wangtile tileid="226" wangid="0,0,1,0,1,0,1,0"/>
   <wangtile tileid="227" wangid="0,0,0,0,1,0,1,0"/>
   <wangtile tileid="256" wangid="1,0,0,0,1,0,0,0"/>
   <wangtile tileid="257" wangid="1,0,1,0,1,0,0,0"/>
   <wangtile tileid="258" wangid="1,0,1,0,1,0,1,0"/>
   <wangtile tileid="259" wangid="1,0,0,0,1,0,1,0"/>
   <wangtile tileid="288" wangid="1,0,0,0,0,0,0,0"/>
   <wangtile tileid="289" wangid="1,0,1,0,0,0,0,0"/>
   <wangtile tileid="290" wangid="1,0,1,0,0,0,1,0"/>
   <wangtile tileid="291" wangid="1,0,0,0,0,0,1,0"/>
  </wangset>
  <wangset name="floors" type="corner" tile="-1">
   <wangcolor name="purple floor" color="#ff0000" tile="-1" probability="1"/>
   <wangtile tileid="1" wangid="0,0,0,1,0,0,0,0"/>
   <wangtile tileid="2" wangid="0,0,0,1,0,1,0,0"/>
   <wangtile tileid="3" wangid="0,0,0,0,0,1,0,0"/>
   <wangtile tileid="33" wangid="0,1,0,1,0,0,0,0"/>
   <wangtile tileid="34" wangid="0,1,0,1,0,1,0,1"/>
   <wangtile tileid="35" wangid="0,0,0,0,0,1,0,1"/>
   <wangtile tileid="65" wangid="0,1,0,0,0,0,0,0"/>
   <wangtile tileid="66" wangid="0,1,0,0,0,0,0,1"/>
   <wangtile tileid="67" wangid="0,0,0,0,0,0,0,1"/>
   <wangtile tileid="97" wangid="0,1,0,0,0,1,0,1"/>
   <wangtile tileid="98" wangid="0,1,0,1,0,0,0,1"/>
   <wangtile tileid="129" wangid="0,0,0,1,0,1,0,1"/>
   <wangtile tileid="130" wangid="0,1,0,1,0,1,0,0"/>
  </wangset>
 </wangsets>
</tileset>
