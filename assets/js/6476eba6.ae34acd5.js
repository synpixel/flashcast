"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[827],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>f});var r=n(67294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function l(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?l(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):l(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function i(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},l=Object.keys(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var c=r.createContext({}),s=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=s(e.components);return r.createElement(c.Provider,{value:t},e.children)},u="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},d=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,l=e.originalType,c=e.parentName,p=i(e,["components","mdxType","originalType","parentName"]),u=s(n),d=a,f=u["".concat(c,".").concat(d)]||u[d]||m[d]||l;return n?r.createElement(f,o(o({ref:t},p),{},{components:n})):r.createElement(f,o({ref:t},p))}));function f(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var l=n.length,o=new Array(l);o[0]=d;var i={};for(var c in t)hasOwnProperty.call(t,c)&&(i[c]=t[c]);i.originalType=e,i[u]="string"==typeof e?e:a,o[1]=i;for(var s=2;s<l;s++)o[s]=n[s];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}d.displayName="MDXCreateElement"},22175:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>o,default:()=>m,frontMatter:()=>l,metadata:()=>i,toc:()=>s});var r=n(87462),a=(n(67294),n(3905));const l={sidebar_position:2},o="Usage",i={unversionedId:"usage",id:"usage",title:"Usage",description:"Examples",source:"@site/docs/usage.md",sourceDirName:".",slug:"/usage",permalink:"/flashcast/docs/usage",draft:!1,editUrl:"https://github.com/synpixel/flashcast/edit/main/docs/usage.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"defaultSidebar",previous:{title:"Getting Started",permalink:"/flashcast/docs/intro"}},c={},s=[{value:"Examples",id:"examples",level:2}],p={toc:s},u="wrapper";function m(e){let{components:t,...n}=e;return(0,a.kt)(u,(0,r.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"usage"},"Usage"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-lua"},"local SPEED = 25\nlocal MAX_DISTANCE = 1000\nlocal GRAVITY = Vector3.new(0, -workspace.Gravity, 0)\n\nlocal function gravity(bullet: Flashcast.Bullet, deltaTime: number)\n    local parallelComponent = bullet.direction:Dot(GRAVITY.Unit) * GRAVITY.Unit\n    local perpendicularComponent = bullet.direction - parallelComponent\n    local newDirection = perpendicularComponent + (parallelComponent + GRAVITY * deltaTime)\n\n    bullet.direction = newDirection.Unit * bullet.direction.Magnitude\nend\n\nlocal function maxDistance(bullet: Flashcast.Bullet)\n    if bullet.distanceTraveled > MAX_DISTANCE then\n        bullet:stop()\n    end\nend\n\nlocal flashcast = Flashcast.new()\nlocal behavior = Flashcast.createBehavior()\n    :setDesiredFramerate(10) -- the bullet will move every 1 / 10 seconds\n    :beforeStep(maxDistance) -- applies a max distance check before moving the bullet\n    :afterStep(gravity) -- applies gravity after moving the bullet\n\nlocal direction = Random.new():NextUnitVector()\nlocal bullet = flashcast:spawnBullet(\n    behavior,\n    Vector3.new(0, 10, 0),\n    direction * SPEED\n)\n")),(0,a.kt)("h2",{id:"examples"},"Examples"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("a",{parentName:"li",href:"https://www.roblox.com/games/17695354946/Flashcast-Example-1"},"https://www.roblox.com/games/17695354946/Flashcast-Example-1")),(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("a",{parentName:"li",href:"https://www.roblox.com/games/17696744681/Flashcast-Example-2"},"https://www.roblox.com/games/17696744681/Flashcast-Example-2"))))}m.isMDXComponent=!0}}]);