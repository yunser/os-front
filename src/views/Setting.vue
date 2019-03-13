<template>
    <my-page title="设置">
        <ul class="wallpaper-list">
            <li class="item" v-for="item in wallpapers">
                <img class="img" :src="item">
            </li>

        </ul>
        <div>这是关于页面</div>
        <div>版本：{{ version }}</div>
    </my-page>
</template>

<script>
    export default {
        data () {
            return {
                wallpapers: [
                    '/static/bg/1.jpg',
                    '/static/bg/2.jpg',
                    '/static/bg/3.jpg',
                    '/static/bg/4.jpg',
                    '/static/bg/5.jpg',
                ],
                version: ''
            }
        },
        mounted() {
            this.$http.get('/version').then(
                response => {
                    let data = response.data
                    if (data.code === 200) {
                        console.log(data)
                        this.version = data.data
                    }
                },
                response => {
                    console.log(response)
                })
//            this.$http.post('/example', this.$qs.stringify({
//                param1: 'value1',
//                param2: 'value2'
//            })).then(
//                response => {
//                    let data = response.data
//                    if (data.code === 200) {
//                        console.log(data.data)
//                    }
//                },
//                response => {
//                    console.log(response)
//                })
        }
    }
</script>

<style lang="scss" scoped>
.wallpaper-list {
    display: flex;
    .item {

    }
    .img {
        width: 80px;
    }
}
</style>
