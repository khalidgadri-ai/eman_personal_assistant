package com.khalidibrahimgadri.eman

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity بدل FlutterActivity: يشارك محرك Flutter مع خدمة صوت التأمل
// (audio_service) فيستمر الصوت والشاشة مطفأة.
class MainActivity : AudioServiceActivity()
