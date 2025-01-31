# Generated by Django 5.1.4 on 2025-01-28 15:21

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0010_passwordresetotp'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='avatarUrl',
            field=models.CharField(default='../../Flutter_Y/assets/images/default_profile.png', max_length=100),
        ),
        migrations.AddField(
            model_name='user',
            name='is_vip',
            field=models.BooleanField(default=False),
        ),
    ]
