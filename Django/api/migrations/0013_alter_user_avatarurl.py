# Generated by Django 5.1.4 on 2025-01-30 17:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0012_alter_user_avatarurl'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='avatarUrl',
            field=models.CharField(max_length=100),
        ),
    ]
