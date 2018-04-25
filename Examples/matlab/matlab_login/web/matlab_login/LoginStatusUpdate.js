define(["dojo/_base/declare",
        "dojo/aspect",
        "dojo/_base/lang",
        "mw-messageservice/MessageService"],
    function (declare, aspect, lang, MessageService) {
        return declare(null, {
            constructor: function (callback) {
                this._handleMethod = callback;
                aspect.after(MessageService, "onConnected", lang.hitch(this, this.start), false);
                MessageService.start();
            },
            start: function () {
                console.warn("this is the start method: " + this._started);
                this._lrpChannel = "/LoginChannel";
                var thisPtr = this;
                if (!this._started) {
                    MessageService.subscribe(this._lrpChannel,
                        this._handleMessage,
                        this)
                        .then(function () {
                            // any post-subscribe setup here
                            thisPtr._started = true;
                        });
                }
            },
            stop: function () {
                if (this._started) {
                    MessageService.unsubscribe(this._lrpChannel,
                        this._handleMessage,
                        this);
                    MessageService.stop();
                    this._started = false;
                }
            },
            _handleMessage: function (msg) {
                var channel = msg.channel;
                var data = msg.data;
                console.log(data);
                var loginInfo = JSON.parse(data);
                this._handleMethod(loginInfo)
            }
        });
    });