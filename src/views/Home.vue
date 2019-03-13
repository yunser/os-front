<template>
    <div>
        <div class="desktop" :style="{'background-image': 'url(' + bgUrl + ')'}">
            <ul id="tool-list" class="tool-list">
                <li class="list-item" v-for="item in apps" @click="openApp(item)">
                    <!-- <a href="/draw2" target="_blank"> -->
                        <img class="img" :src="item.icon">
                        <div class="text">{{ item.name }}</div>
                    <!-- </a> -->
                </li>
            </ul>
            <div class="tastbar">
                <ul class="tast-app-list">
                    <!-- <li><a id="start-menu" href="#" @click.prevent="toggleStart"><img src="/static/img/start-menu.jpg"></a>  </li> -->
                    <!--<li><a href="#"><img src="asset/img/app-color.jpg"></a>  </li>-->
                </ul>
                <a id="date" class="time" href="#">2016-11-30</a>
            </div>
        </div>
        <div id="start-box" class="start-box" v-if="startVisible">
            <canvas class = "canvas" id="canvasId" width = '400px' height = '400px'></canvas>
            <div id="time" class="time">20:38</div>
        </div>

        <div :class="['window', app.id === activeApp.id ? 'window-active' : '']"
            :style="windowStyle(app)" v-for="app, index in dockApps" @click="onAppClick(app, index)" v-show="app.windowAttr.visible">
            <div class="header" @mousedown="onMouseDown($event, app, 'header')">
                <div class="title">{{ app.name }}
                    <div style="display: none">{{ app.asd }}</div>
                </div>
                <div class="btns">
                    <div class="btn btn-min" @click="min(app, index)" title="最小化"></div>
                    <div class="btn btn-max" @click="max(app, index)" title="最大化/还原"></div>
                    <div class="btn btn-close" @click="close(app, index)" title="关闭"></div>
                </div>
            </div>
            <div class="body">
                <iframe class="iframe" :src="app.url" :style="{'pointer-events': mask ? 'none' : 'auto'}" @load="onIfarameLoad($event, app)"></iframe>
            </div>
            <div class="line line-top" @mousedown="onMouseDown($event, app, 'top')"></div>
            <div class="line line-bottom" @mousedown="onMouseDown($event, app, 'bottom')"></div>
            <div class="line line-left" @mousedown="onMouseDown($event, app, 'left')"></div>
            <div class="line line-right" @mousedown="onMouseDown($event, app, 'right')"></div>
        </div>

        <div class="dock-wrap">
            <div class="dock" v-if="dockApps.length">
                <ul class="dock-app-list">
                    <li class="item" v-for="item in dockApps" @click="openDockApp(item, index)" :title="item.name">
                        <img class="icon" :src="item.icon">
                        <div class="name">{{ item.name }}</div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
    /* eslint-disable */
    // 计算右下角时间
    var date = new Date();
    var dateStr = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    //document.getElementById('date').innerHTML = dateStr;


    var Canvas = {};

    //Canvas.cxt = document.getElementById('canvasId').getContext('2d');

    Canvas.Point = function(x, y){
        this.x = x;
        this.y = y;
    };

    /*擦除canvas上的所有图形*/
    Canvas.clearCxt = function(){
        var me = this;
        var canvas = me.cxt.canvas;
        me.cxt.clearRect(0,0, canvas.offsetWidth, canvas.offsetHeight);
    };

    /*时钟*/
    Canvas.Clock = function(){
        var me = Canvas,
            c = me.cxt,
            radius = 150, /*半径*/
            scale = 20, /*刻度长度*/
            minangle = (1/30)*Math.PI, /*一分钟的弧度*/
            hourangle = (1/6)*Math.PI, /*一小时的弧度*/
            hourHandLength = radius/2, /*时针长度*/
            minHandLength = radius/3*2, /*分针长度*/
            secHandLength = radius/10*9 - 2, /*秒针长度*/
            center = new me.Point(c.canvas.width/2, c.canvas.height/2); /*圆心*/

        /*绘制圆心（表盘中心）*/
        function drawCenter(){
            c.save();

            c.translate(center.x, center.y);

            c.fillStyle = '#fff';
            c.beginPath();
            c.arc(0, 0, radius/20, 0, 2*Math.PI);
            c.closePath();
            c.fill();
            c.stroke();

            c.restore();
        };

        /*通过坐标变换绘制表盘*/
        function drawBackGround(){
            c.save();

            c.translate(center.x, center.y); /*平移变换*/
            // 绘制刻度
            function drawScale(scale){
                c.moveTo(radius - scale, 0);
                c.lineTo(radius, 0);
            };

            c.strokeStyle = '#fff';
            c.lineWidth = 2;
            c.beginPath();
            c.arc(0, 0, radius, 0, 2*Math.PI, true);
            c.closePath();

            for (var i = 1; i <= 12; i++) {
                var scale = ((i - 1) % 3 === 0) ? 18 : 12;
                drawScale(scale);
                c.rotate(hourangle); /*旋转变换*/
            };

            c.stroke();

            c.restore();
        };

        // 绘制时针
        this.drawHourHand = function(h){
            h = h === 0? 24: h;

            c.save();
            c.translate(center.x, center.y);
            c.rotate(3/2*Math.PI);

            c.rotate(h*hourangle);

            c.strokeStyle = '#fff';
            c.lineWidth = 2;
            c.beginPath();
            c.moveTo(0, 0);
            c.lineTo(hourHandLength, 0);
            c.stroke();
            c.restore();
        };

        /*绘制分针（m: 当前分）*/
        this.drawMinHand = function(m){

            m = m === 0? 60: m;

            c.save();
            c.translate(center.x, center.y);
            c.rotate(3/2*Math.PI);

            c.rotate(m*minangle);

            c.strokeStyle = '#fff';
            c.beginPath();
            c.moveTo(0, 0);
            c.lineTo(minHandLength, 0);
            c.stroke();
            c.restore();
        };

        /*绘制秒针（s：当前秒）*/
        this.drawSecHand = function(s){

            s = s === 0? 60: s;

            c.save();
            c.translate(center.x, center.y);
            c.rotate(3/2*Math.PI);

            c.rotate(s*minangle);

            c.strokeStyle = '#eb584d';
            c.beginPath();
            c.moveTo(0, 0);
            c.lineTo(secHandLength, 0);
            c.stroke();
            c.restore();
        };

        /*依据本机时间绘制时钟*/
        this.drawClock = function(){
            var me = this;

            function draw(){
                var date = new Date();

                Canvas.clearCxt();

                drawBackGround();
                drawCenter();
                me.drawHourHand(date.getHours() + date.getMinutes()/60);
                me.drawMinHand(date.getMinutes() + date.getSeconds()/60);
                me.drawSecHand(date.getSeconds());

                // 显示时间数字
                var date = new Date();
                var timeStr = date.getHours() + ':' + date.getMinutes();
                document.getElementById('time').innerHTML = timeStr;
            }
            draw();
            setInterval(draw, 1000);
        };
    };
    
    export default {
        data () {
            return {
                bgUrl: '/static/bg/1.jpg',
                mask: false,
                dockApps: [
                    // {
                    //     id: '1',
                    //     name: '百度',
                    //     url: 'https://www.baidu.com/',
                    //     icon: 'https://work.yunser.com/static/img/text.svg',
                    //     windowAttr: {
                    //         x: 100,
                    //         y: 100,
                    //         width: 300,
                    //         height: 600,
                    //         zIndex: 1,
                    //         visible: true
                    //     },
                    // },
                    // {
                    //     id: '3',
                    //     name: '计算器',
                    //     url: 'https://calculator.yunser.com/calculator?embed=true',
                    //     icon: 'https://work.yunser.com/static/img/calculator_simple.svg',
                    //     windowAttr: {
                    //         x: 500,
                    //         y: 100,
                    //         width: 1000,
                    //         height: 600,
                    //         zIndex: 2,
                    //         visible: true
                    //     },

                    // }
                ],
                activeApp: {
                    id: '1',
                    name: '百度',
                    url: 'https://www.baidu.com/',
                    icon: 'https://work.yunser.com/static/img/text.svg',
                    windowAttr: {
                        x: 100,
                        y: 100,
                        width: 1000,
                        height: 600
                    },
                },
                apps: [
                    {
                        id: '1',
                        name: '百度',
                        url: 'https://www.baidu.com/',
                        icon: 'https://work.yunser.com/static/img/text.svg',
                        asd: 'asd'
                    },
                    {
                        id: '2',
                        name: '应用商店',
                        url: 'https://app.yunser.com/',
                        icon: 'https://www.yunser.com/static/img/build.svg',
                        asd: 'asd'
                    },
                    {
                        id: '3',
                        name: '计算器',
                        url: 'https://calculator.yunser.com/calculator?embed=true',
                        icon: 'https://work.yunser.com/static/img/calculator_simple.svg',
                        asd: 'asd'
                    },
                    {
                        id: '4',
                        name: '关于',
                        url: 'https://project.yunser.com/products/89205e1029b511e9ae78ad50f0fc9a55',
                        icon: 'https://work.yunser.com/static/img/text.svg',
                        asd: 'asd'
                    },
                    {
                        id: '5',
                        name: '设置',
                        url: '/settings?embed=true',
                        icon: '/static/img/settings.png',
                        asd: 'asd'
                    }
                ],
                startVisible: false,
                page: {
                    menu: [
                        {
                            type: 'icon',
                            icon: 'help',
                            to: '/help'
                        }
                    ]
                }
            }
        },
        computed: {
            
        },
        mounted() {
            document.title = '系统'

            document.addEventListener('mousemove', this._onMouseMove = e => {
                this.onMouseMove(e)
            })
            document.addEventListener('mouseup', this._onMouseUp = e => {
                this.onMouseUp(e)
            })

            // this.openApp(this.apps[4])
        },
        destroyed() {
            document.removeEventListener('mousemove', this._onMouseMove)
            document.removeEventListener('mouseup', this._onMouseUp)
        },
        methods: {
            onIfarameLoad(e, app) {
                console.log('load', e)
                // e.path[0].contentDocument.onclick = function () {
                //     console.log('click')
                //     var sidebar = document.getElementById('sidebar');
                //     if (sidebar.style.display == 'block')  sidebar.style.display = 'none';
                // };
            },
            onAppClick(app, index) {
                this.active(app)
            },
            active(app) {
                this.activeApp = app
                let max = 0
                for (let item of this.dockApps) {
                    if (item.windowAttr.zIndex > max) {
                        max = item.windowAttr.zIndex
                    }
                }
                app.windowAttr.zIndex = max + 1
            },
            windowStyle(app) {
                return {
                    top: app.windowAttr.y + 'px',
                    left: app.windowAttr.x + 'px',
                    width: app.windowAttr.width + 'px',
                    height: app.windowAttr.height + 'px',
                    'z-index': app.windowAttr.zIndex || '1'
                }
            },
            onMouseDown(e, app, type) {
                this.opApp = app
                console.log(e)
                this.downX = e.pageX
                this.downY = e.pageY
                this.isDown = true
                console.log('down')

                this.downType = type
                this.originX = this.opApp.windowAttr.x
                this.originY = this.opApp.windowAttr.y
                this.originWidth = this.opApp.windowAttr.width
                this.originHeight = this.opApp.windowAttr.height
            },
            onMouseUp(e) {
                console.log('up')
                this.isDown = false
                this.mask = false
            },
            onMouseMove(e) {
                console.log('move', this.downType)
                if (!this.isDown) {
                    return
                }
                this.mask = true
                console.log('e.pageY', e.pageY)

                let offsetX = e.pageX - this.downX
                let offsetY = e.pageY - this.downY

                if (this.downType === 'header') {
                    this.opApp.windowAttr.x = this.originX + offsetX
                    this.opApp.windowAttr.y = this.originY + offsetY
                    console.log('shezhi', this.originY + offsetY)
                } else if (this.downType === 'top') {
                    this.opApp.windowAttr.y = this.originY + offsetY
                    this.opApp.windowAttr.height = this.originHeight - offsetY
                } else if (this.downType === 'bottom') {
                    this.opApp.windowAttr.height = this.originHeight + offsetY
                } else if (this.downType === 'left') {
                    this.opApp.windowAttr.x = this.originX + offsetX
                    this.opApp.windowAttr.width = this.originWidth - offsetX
                } else if (this.downType === 'right') {
                    this.opApp.windowAttr.width = this.originWidth + offsetX
                }
                this.opApp.asd = new Date().getTime()
            },
            openDockApp(app, index) {
                console.log('dock', app)
                app.windowAttr.visible = true
                this.active(app)
                // this.$set(this.$data.dockApps[index], 'windowAttr', app.windowAttr)
                if (app.windowAttr.visible) {

                }
                app.asd = new Date().getTime()
            },
            openApp(item) {
                let matchItem = this.dockApps.find(it => it.id === item.id)
                if (matchItem) {

                } else {
                    item.windowAttr = {
                        x: 100,
                        y: 100,
                        width: 1000,
                        height: 600,
                        zIndex: 1,
                        visible: true
                    }
                    this.dockApps.push(item)
                }
            },
            close(app) {
                for (let i = 0; i < this.dockApps.length; i++) {
                    if (this.dockApps[i].id === app.id) {
                        this.dockApps.splice(i, 1)
                        // this.$set()
                        break
                    }
                }
            },
            min(app, index) {
                console.log('min', app)
                app.windowAttr.visible = false
                // this.dockApps[index].visible = false
                // this.$set(this.$data.dockApps, this.dockApps)
                app.asd = new Date().getTime()
            },
            max(app) {
                if (app.windowAttr.isMax) {
                    app.windowAttr.isMax = false
                    app.windowAttr.x = app.originWindowAttr.x
                    app.windowAttr.y = app.originWindowAttr.y
                    app.windowAttr.width = app.originWindowAttr.width
                    app.windowAttr.height = app.originWindowAttr.height
                    app.asd = new Date().getTime()
                } else {
                    app.windowAttr.isMax = true
                    app.originWindowAttr = {
                        x: app.windowAttr.x,
                        y: app.windowAttr.y,
                        width: app.windowAttr.width,
                        height: app.windowAttr.height,
                    }
                    app.windowAttr.x = 0
                    app.windowAttr.y = 0
                    app.windowAttr.width = window.innerWidth
                    app.windowAttr.height = window.innerHeight
                    app.asd = new Date().getTime()
                }
            },
            toggleStart() {
                this.startVisible = !this.startVisible
                if (this.startVisible) {
                    this.$nextTick(() => {
                        var clock = new Canvas.Clock();
                        clock.drawClock();
                    })
                }
            }
        }
    }
</script>

<style lang="scss" scoped>
/**/
.dock-app-list {
    display: flex;
    .item {
        position: relative;
        cursor: pointer;
    }
    .icon {
        width: 64px;
        height: 64px;
    }
    .name {
        display: none;
        position: absolute;
        top: 0;
        left: 0;
        color: #fff;
        padding: 8px 16px;
        background-color: #000;
    }
}
.dock {
    position: relative;
    z-index: 10000000;
    // width: 100px;
    height: 80px;
    padding: 8px 16px 0 16px;
    background-color: #333;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
}
.dock-wrap {
    display: flex;
    justify-content: center;
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 80px;
    z-index: 1000000000;
    // background-color: #f00;
}
.window {
    position: relative;
    position: fixed;
    top: 230px;
    left: 130px;
    width: 1000px;
    height: 300px;
    background-color: #000;
    border: 1px solid #555;
    border-radius: 4px;
    overflow: hidden;
    .header {
        height: 24px;
        background-color: #3c3c3c;
        user-select: none;
        cursor: move;
        .btns {
            display: flex;
            align-items: center;
            height: 100%;
            position: absolute;
            top: 0;
            right: 0;
            height: 24px;
            padding-right: 12px;
        }
        .btn {
            width: 12px;
            height: 12px;
            margin-left: 12px;
            border-radius: 50%;
            cursor: pointer;
        }
        .btn-close {
            background-color: rgb(95, 31, 25);
        }
        .btn-min {
            background-color: rgb(92, 70, 5);
        }
        .btn-max {
            background-color: rgb(28, 82, 42);
        }
    }
    .title {
        line-height: 24px;
        text-align: center;
        color: #bbb;
    }
    .body {
        position: absolute;
        top: 24px;
        left: 0;
        right: 0;
        bottom: 0;
        // border: 1px solid #f00;
        background-color: #fff;
        overflow: hidden;
    }
    .iframe {
        display: block;
        width: 100%;
        height: 100%;
        border: none;
        overflow: auto;
        // pointer-events: 
        // pointer-events: none;
    }
    .line {
        position: absolute;
        // background-color: #f00;
        user-select: none;
    }
    .line-bottom {
        position: absolute;
        left: 0;
        bottom: 0;
        width: 100%;
        height: 2px;
        cursor: ns-resize;
    }
    .line-top {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        height: 2px;
        cursor: ns-resize;
    }
    .line-left {
        position: absolute;
        left: 0;
        top: 0;
        width: 2px;
        height: 100%;
        cursor: ew-resize;
    }
    .line-right {
        position: absolute;
        right: 0;
        top: 0;
        width: 2px;
        height: 100%;
        cursor: ew-resize;
    }
}
.desktop {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    padding: 82px 32px 32px 32px;
    background-image: url("/static/img/desktop-bg.jpg");
    background-color: #f1f1f1;
    background-size: 100% 100%;
}
.window-active {
    .header {
        .btn-close {
            background-color: #EA4335;
        }
        .btn-min {
            background-color: #FBBC05;
        }
        .btn-max {
            background-color: #34A853;
        }
    }
}
/**/
.tool-list {
    display: flex;
    li {
        // width: 260px;
        height: 96px;
        padding: 8px;
        margin-bottom: 16px;
        margin-right: 8px;
        // background-color: #fff;
        // border: 1px solid #ccc;
        text-align: center;
        cursor: pointer;
        &:hover {
            border-color: #09c;
        }
        &.active {
            border: 1px solid #f00;
        }
        a {
            color: #666;
        }
        .img {
            float: left;
            width: 72px;
            height: 72px;
            margin-bottom: 16px;
            // background-color: #fff;
            // border: 1px solid #ccc;
            border-radius: 8px;
        }
        .info {
            float: left;
        }
    }
    .text {
        // font-size: 18px;
        color: #000;
    }
}
.tool-list .header {
    overflow: hidden;
}
.tool-list .desc {
    max-width: 150px;
    margin-top: 8px;
}
/* tastbar */
.tastbar {
    position: absolute;
    top: 0;
    left: 0;
    // display: none;
    width: 100%;
    height: 40px;
    background-color: rgba(0, 0, 0, .8);
}
.tastbar .time {
    float: right;
    padding: 14px 16px;
    color: #fff;
}
.tast-app-list {

}
.tast-app-list li {
    float: left;
    width: 54px;
    // height: 48px;
}
.tast-app-list li:hover {
    background-color: rgba(0,0,0,.2);
}
.tast-app-list li img {
    display: block;
    width: 36px;
    height: 36px;
    margin: 6px auto;
}
.start-box {
    position: absolute;
    // display: none;
    width: 600px;
    height: 400px;
    bottom: 48px;
    left: 0;
    background-color: rgba(0,0,0,.6);
}
.start-box .time {
    position: absolute;
    right: 64px;
    bottom: 32px;
    color: #fff;
    font-size: 48px;
    font-weight: 100;
}

</style>
