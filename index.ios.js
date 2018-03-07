/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button,
    NativeModules,
    Image
} from 'react-native';

var DataModule = require('react-native').NativeModules.DataModule;

export default class IOSNativeModule extends Component {
    constructor(props) {
        super(props);
        this.state = {
            avatarSource:null,
        };
    }
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
        <Image source={this.state.avatarSource ? this.state.avatarSource : require('./sad.jpg')}
               style={{width:120,height:80}}/>
        <Button title="跳转原生相册" onPress={() => {
            console.log("***********");
            DataModule.openImagePickerWithResolver().then((data) => {
                this.setState({
                    avatarSource:{uri:data}
                })
            }).catch((err) => {
                console.log(err)
            });
        }}/>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('IOSNativeModule', () => IOSNativeModule);
